# Introdução ####

# Esse script tem como objetivo criar uma base com  12 indicadores a nível municipal
# para os 92 municípios do Rio de Janeiro que foram construídos a partir da base
# do Censo 2022. Foi utilizado o pacote censobr para fazer a importação dos dados
# do Censo 2022.


# 1 - Importação dos pacotes ##################################################

# Linha de código para apagar todos os objetos do environment para evitar sobreposições
rm(list=ls())

# O primeiro passo é a instalação dos pacotes necessários. Caso você nunca tenha
# instalado no R esses pacotes, descomentar a próxima linha para fazer a instalação
# antes de usar o library

# install.packages("arrow")
# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("naniar")
# install.packages("skimr")
# install.packages("gt")
# install.packages("readxl")
# install.packages("openxlsx")

# Mesmo que você já tenha instalado os pacotes anterios, é necessário instalar o
# pacote do censobr. Caso você já tenha instalado, comentar a próxima linha.
install.packages("censobr")

# Liberando os pacotes necessários para a criação dos indicadores
library(censobr)
library(arrow)
library(tidyverse)
library(dplyr)
library(naniar)
library(skimr)
library(gt)
library(readxl)
library(openxlsx)

# 2 - Importação das bases do Censo ############################################

# HELP da função utilizada nesse script
?censobr::read_tracts

# Acesso ao dicionário dos codigos
censobr::data_dictionary(year = 2022, dataset = "tracts")

# Tabela basica do censobr apenas 36 variáveis
basico <- read_tracts(
  year = 2022,
  dataset = 'Basico',
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE #trocar pra true após o primeiro download
) %>%
  filter(code_state == 33)

# No estado do Rio de Janeiro há 41700 malhas de setores censitários.

# Verificando os nomes das variaveis disponiveis
basico %>%
  variable.names()

# Verificando se a partir dos dados censitários, agrupando por município, retornará os 92 municípios existentes no Estado do Rio de Janeiro
verificação = basico %>%
  filter(code_state == 33) %>%
  select(code_muni,name_muni) %>%
  group_by(name_muni) %>%
  summarise(n=n())

# Dados do censo 2022 por setor censitário referente as pessoas
pessoas <- read_tracts(
  year = 2022,
  dataset = "Pessoas",
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE
)%>%
  filter(code_state == 33)

# Dados do censo 2022 por setor censitário referente ao domicilio
domicilio <- read_tracts(
  year = 2022,
  dataset = "Domicilio",
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE
)%>%
  filter(code_state == 33)

# Dados do censo 2022 por setor censitário referente ao domicilio
responsavel_renda <- read_tracts(
  year = 2022,
  dataset = "ResponsavelRenda",
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE
)%>%
  filter(code_state == 33)



## 2.1 - Manipulação das 4 bases do censo para juntar em apenas uma base ####

# Verficando quais são as variáveis presentes nas 4 bases que importamos no Script
#é essencial para fazermos o join corretamente.
intersect(names(basico), names(pessoas)) |> intersect(names(domicilio)) |> intersect(names(responsavel_renda))

# Criando um vetor com as 29 primeiras variáveis do basico
chaves <- names(basico)[1:29]
# Fazendo o join usando apenas essas variáveis como chave
base <- basico %>%
  left_join(pessoas, by = chaves) %>%
  left_join(domicilio, by = chaves) %>%
  left_join(responsavel_renda, by = chaves)

## 2.2 - Manipulação para fazer o agrupando da base por nível municipal ####

# Variáveis fixas que não podem ser somadas
fixas_proibidas <- c(
  "code_tract",
  "situacao", "code_situacao", "code_type",
  "code_district", "name_district",
  "code_subdistrict", "name_subdistrict",
  "code_neighborhood", "name_neighborhood",
  "code_nucleo_urbano", "name_nucleo_urbano",
  "code_favela", "name_favela",
  "code_aglomerado", "name_aglomerado",
  "code_muni", "name_muni",
  "area_km2"
)

# Fixas válidas = primeiras 29 menos fixas proibidas
fixas <- names(base)[1:29]
fixas_validas <- setdiff(fixas, fixas_proibidas)

# Variáveis que nunca devem ser somadas
nao_somar <- c(fixas_proibidas, fixas_validas)

# Variáveis numéricas que podem ser agregadas
variaveis_somar <- base %>%
  select(-all_of(nao_somar)) %>%
  select(where(is.numeric)) %>%
  names()

# Remover code_muni por segurança
variaveis_somar <- setdiff(variaveis_somar, "code_muni")

# ---- VARIÁVEIS DE RENDA QUE DEVEM SER AGRUPADAS POR MÉDIA ----
variaveis_renda <- c("V06001", "V06002", "V06003", "V06004", "V06005")

# Variáveis somáveis EXCLUINDO as de renda
variaveis_soma_final <- setdiff(variaveis_somar, variaveis_renda)

# Agregando a base a nível municipal
base_mun <- base %>%
  group_by(code_muni, name_muni) %>%
  summarise(
    across(all_of(fixas_validas), first),

    # Área deve ser sempre somada
    area_km2 = sum(area_km2, na.rm = TRUE),

    # SOMA para todas as variáveis numéricas exceto renda
    across(all_of(variaveis_soma_final), ~ sum(.x, na.rm = TRUE)),

    # MÉDIA para as variáveis de renda
    across(all_of(variaveis_renda), ~ mean(.x, na.rm = TRUE)),

    .groups = "drop"
  )

# Retirada de variáveis não utilizadas
base_mun <- base_mun |>
  select(
    -c(code_intermediate, name_intermediate,
       code_immediate, name_immediate,
       code_urban_concentration, name_urban_concentration)
  )

# Verificando dados faltantes
gg_miss_var(base_mun)
glimpse(base_mun)

#Transformando a variável code_muni em fator
base_mun$code_muni = as.factor(base_mun$code_muni)

## 2.3 - Exportando a base a nível municipal ####

# base_mun |>
#   write_csv2(file = "Bases/base_censo2022_rj.csv")

#exportando em xslx, buscando maior eficiencia e reprodutibildiade de dados
base_mun %>%
  write_excel_csv2(file = "Bases/base_censo2022_rj.xlsx" )

# apagar todos os objetos diferente da base que vamos usar para desenvolver os indicadores
rm(list = setdiff(ls(), "base_mun"))


#export em txt por tamanho do arquivo
base_mun %>%
  write_delim(file = "Bases/base_censo2022_rj.txt",delim = ";")


# deixar só o base_mun
##rm(list = ls()[ls() != "base_mun"])



# 3 - Indicadores ##############################################################

## Indicadores Demográficos ####

### 3.1 - Indicador de densidade demográfica ####
ind1 <- base_mun %>%
  mutate(densidade_demografica = V0001 / area_km2) %>%
  select(code_muni, name_muni, densidade_demografica)

ind1 <- ind1 |>
  rename(densidade_demografica = densidade_demografica)

summary(ind1)
# Não há dados faltantes




### 3.2 - Indicador do Índice de Urbanização ####


ind2 = basico %>%
  group_by(code_muni,name_muni,situacao) %>%
  summarise(pop = sum(V0001,na.rm = T) ) %>%
  pivot_wider(names_from = situacao,values_from = pop) %>%
  mutate(urbanizacao = sum(Urbana,na.rm = T)/(sum(Urbana,na.rm = T) + sum(Rural,na.rm = T)+ sum(NA,na.rm = T))) %>%
  select(code_muni,name_muni,urbanizacao) %>%
  mutate(code_muni = as_factor(code_muni))

ind2 = ind2 %>%
  mutate(urbanizacao = 100* urbanizacao)

ind2 <- ind2 |>
  rename(IU = urbanizacao)

summary(ind2)
# Não há dados faltantes



### 3.3 - Indicador da Razão de Dependência ####
ind3 <- base_mun %>%
  mutate(
    pop_0_14   = demografia_V01031 +
      demografia_V01032 +
      demografia_V01033,
    pop_15_59  = demografia_V01034 +
      demografia_V01035 +
      demografia_V01036 +
      demografia_V01037 +
      demografia_V01038 +
      demografia_V01039,
    pop_60mais =
      demografia_V01040 +
      demografia_V01041,
    razao_dependencia = (pop_0_14 + pop_60mais) / pop_15_59
  ) %>%
  select(code_muni, name_muni, razao_dependencia)

ind3 <- ind3 |>
  rename(razao_dependencia = razao_dependencia)

summary(ind3)
# Não há dados faltantes




### 3.4 - Indicador da Proporção de Idosos (65+) ####
ind4 <- base_mun %>%
  mutate(
    pop_60mais = demografia_V01040 + demografia_V01041,
    proporcao_idosos = pop_60mais / V0001
  ) %>%
  select(code_muni, name_muni, proporcao_idosos)

ind4 = ind4 %>%
  mutate(proporcao_idosos = 100* proporcao_idosos)

ind4 <- ind4 |>
  rename( IPI = proporcao_idosos)

summary(ind4)
# Não há dados faltantes


### 3.5 - Indicador da Predominancia de Raca ####

ind5 <- base_mun %>%
  group_by(code_muni, name_muni) %>%
  summarise(
    raca_V01317, #Cor ou raça é branca
    raca_V01318, #Cor ou raça é preta
    raca_V01319, #Cor ou raça é amarela
    raca_V01320, #Cor ou raça é parda
    raca_V01321 #Cor ou raça é indígena
  ) %>%
  rowwise() %>%
  mutate(
    raca_predominante = {
      vals <- c_across(c(raca_V01317,
                         raca_V01318,
                         raca_V01319,
                         raca_V01320,
                         raca_V01321))
      nomes <- c("Branca",
                 "Preta",
                 "Amarela",
                 "Parda",
                 "indígena")
      nomes[which.max(vals)]
    }
  ) %>%
  ungroup() %>%
  select(code_muni,name_muni,raca_predominante)

ind5 <- ind5 |>
  rename(IPR = raca_predominante)

### 3.6 - Indicador da Proporção de Chefes Mulheres ####
ind6 <- base_mun %>%
  mutate(
    total_chefes = parentesco_V01062 +
      parentesco_V01063,

    prop_chefes_mulheres = parentesco_V01063 / total_chefes
  ) %>%
  select(code_muni, name_muni, prop_chefes_mulheres)

ind6 = ind6 %>%
  mutate(prop_chefes_mulheres = 100* prop_chefes_mulheres)

ind6 <- ind6 |>
  rename(IPCM = prop_chefes_mulheres)

summary(ind6)
# Não há dados faltantes


### 3.7 - Indicador da Razão de mulheres sobre homens no municipio ####
ind7 <- base_mun %>%
  select(code_muni, name_muni,
         demografia_V01007,#	Sexo masculino
         demografia_V01008#	Sexo feminino
         ) %>%
  mutate(prop_mulher = demografia_V01008 / demografia_V01007) %>%
  select(code_muni, name_muni, prop_mulher)

ind7 <- ind7 |>
  rename(IRMH = prop_mulher)

summary(ind7)
# Não há dados faltantes




### 3.8 - Indicador do Tamanho Médio do Domicílio (pessoas por domicilio) ####
ind8 <- base_mun %>%
  mutate(tamanho_medio_dom = V0001 #total pop
         / domicilio01_V00001 #Domicílios Particulares Permanentes Ocupados
         ) %>%
  select(code_muni, name_muni, tamanho_medio_dom)

ind8 <- ind8 |>
  rename(tamanho_medio_dom = tamanho_medio_dom)

summary(ind8)
# Não há dados faltantes





## Indicadores de Saúde ####

### 3.9 - Indicador da Coleta de Lixo Adequada ####
ind9 <- base_mun %>%
  select(code_muni, name_muni,
         domicilio02_V00397,#		Domicílios Particulares Permanentes Ocupados, Lixo coletado no domicílio por serviço de limpeza
         domicilio02_V00398,#		Domicílios Particulares Permanentes Ocupados, Lixo depositado em caçamba de serviço de limpeza
         domicilio02_V00399,#		Domicílios Particulares Permanentes Ocupados, Lixo queimado na propriedade
         domicilio02_V00400,#		Domicílios Particulares Permanentes Ocupados, Lixo enterrado na propriedade
         domicilio02_V00401,#		Domicílios Particulares Permanentes Ocupados, Lixo jogado em terreno baldio, encosta ou área pública
         domicilio02_V00402#		Domicílios Particulares Permanentes Ocupados, Outro destino do lixo
  ) %>%
  mutate(
    lixo_adequado = domicilio02_V00397 +
      domicilio02_V00398,
    lixo_total= (domicilio02_V00397 +
      domicilio02_V00398 +
      domicilio02_V00399 +
      domicilio02_V00400 +
      domicilio02_V00401 +
      domicilio02_V00402) ,
    coleta_lixo = lixo_adequado / lixo_total
  ) %>%
  select(code_muni, name_muni, coleta_lixo)

ind9 = ind9 %>%
  mutate(coleta_lixo = 100* coleta_lixo)

ind9 = ind9 %>%
  rename(ICLA = coleta_lixo)

summary(ind9)
# Não há dados faltantes




### 3.10 - Indicador do Esgoto Adequado ####
ind10 <- base_mun %>%
  select(code_muni,
         name_muni,
         domicilio02_V00309,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é rede geral ou pluvial
         domicilio02_V00310,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é fossa séptica ou fossa filtro ligada à rede
         domicilio02_V00311,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é fossa séptica ou fossa filtro não ligada à rede
         domicilio02_V00312,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é fossa rudimentar ou buraco
         domicilio02_V00313,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é vala
         domicilio02_V00314,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é rio, lago, córrego ou mar
         domicilio02_V00315,#		Domicílios Particulares Permanentes Ocupados, Destinação do esgoto do banheiro ou sanitário ou buraco para dejeções é outra forma
         domicilio02_V00316	#  	Domicílios Particulares Permanentes Ocupados, Destinação do esgoto inexistente, pois não tinham banheiro nem sanitário
         ) %>%
  mutate(esgoto_adequado = domicilio02_V00309 +
           domicilio02_V00310 +
           domicilio02_V00311,
         total_esgotos = domicilio02_V00309 +
           domicilio02_V00310 +
           domicilio02_V00311 +
           domicilio02_V00312 +
           domicilio02_V00313 +
           domicilio02_V00314 +
           domicilio02_V00315 +
           domicilio02_V00316,
         prop_esgoto_adequado = esgoto_adequado/total_esgotos) %>%
  select(code_muni, name_muni, prop_esgoto_adequado)

ind10 = ind10 %>%
  mutate(prop_esgoto_adequado = 100* prop_esgoto_adequado)

ind10 = ind10 %>%
  rename(IEA = prop_esgoto_adequado)

summary(ind10)
# Não há dados faltantes






## Indicadores Econômicos ####

### 3.11 - Indicador da Razão do Valor do rendimento nominal médio mensal sobre o salario minimo ####
# salario minimo de referencia em dez/2022 = R$ 1212,00
ind11 <- base_mun %>%
  select(code_muni, name_muni,
         V06004#Valor do rendimento nominal médio mensal das pessoas responsáveis com rendimentos por domicílios particulares permanentes ocupados
  ) %>%
  mutate(IRRSM = V06004/1212) %>%
  #mutate(valor_presente = 1518*IRRSM) %>%  # em 11/2025 o salario minimo é de R$1518
  select(code_muni, name_muni, IRRSM#,valor_presente
         )

ind11 = ind11 %>%
  rename(IRRSM = IRRSM)

summary(ind11)
# Não há dados faltantes





### 3.12 - Indicador de Porte Populacional ####
ind12 <- base_mun %>%
  group_by(code_muni,name_muni) %>%
  summarise(
    porte_populacional = case_when(
      (V0001) <= 50000 ~ "Pequeno",
      (V0001) > 50000 & (demografia_V01006) <= 100000 ~ "Médio",
      (V0001) > 100000 & (demografia_V01006) <= 500000 ~ "Grande",
      (V0001) > 50000 ~ "Muito grande",
    )
  )%>%
  select(code_muni, name_muni, porte_populacional)

ind12 = ind12 %>%
  rename(porte_populacional = porte_populacional)

summary(ind12)




# 4 - Base dos indicadores criados acima #######################################
indicadores_df <- ind1 %>%
  left_join(ind2,  by = c("code_muni","name_muni")) %>%
  left_join(ind3,  by = c("code_muni","name_muni")) %>%
  left_join(ind4,  by = c("code_muni","name_muni")) %>%
  left_join(ind5,  by = c("code_muni","name_muni")) %>%
  left_join(ind6,  by = c("code_muni","name_muni")) %>%
  left_join(ind7,  by = c("code_muni","name_muni")) %>%
  left_join(ind8,  by = c("code_muni","name_muni")) %>%
  left_join(ind9,  by = c("code_muni","name_muni")) %>%
  left_join(ind10, by = c("code_muni","name_muni")) %>%
  left_join(ind11, by = c("code_muni","name_muni")) %>%
  left_join(ind12, by = c("code_muni","name_muni"))

# Manipulação para que todos os indicadores tenha apenas 4 casas decimais
indicadores_df <- indicadores_df %>%
  mutate(across(where(is.numeric), ~ round(.x, 4)))

# Visualizando a base de indicadores
View(indicadores_df)


## 4.1 - Exportando a base dos indicadores municipal ####

# buscando eficiencia em compatacação
# indicadores_df |>
#   write_csv2(file = "Bases/base_indicadores_rj.csv")


# Em formato Excel (xlsx) para melhor visualização
openxlsx::write.xlsx(indicadores_df, file = "Bases/base_indicadores_rj.xlsx")



# 99999 - Tabela ajustada - Criando tabela grafica para os indcadores do RJ ##########################

indicadores_df %>%
  select(-code_muni) %>%
  gt() %>%
  tab_header(
    title = md("**Indicadores**"),
    subtitle = md("*Rio de janeiro - Censo 2022*")
  ) %>%
  opt_row_striping() %>%  # colocar linhas alternadas de cor
  cols_align(align = "center")%>%
  cols_align(align = "left", columns = c(name_muni)) %>%  # verificar se vale a pena deixar isso aq
  tab_style(
    style = list(
      cell_fill(color = "lightgrey"),
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  cols_label(
    name_muni = md("Municipios"),
    densidade_demografica = md("Densidade demografica \n (pessoas/km²)"),
    urbanizacao = "Proporção de urbanização", #alterei esse
    razao_dependencia = "Razão de dependencia",
    proporcao_idosos = "Proporção  de idosos",
    prop_chefes_mulheres = "Proporção de chefes de família mulheres",
    prop_mulher = "Razão de mulheres sobre homens no municipio",
    tamanho_medio_dom = "Tamanho médio do domicílio \n (pessoas/domicilio)",
    coleta_lixo="Proporção de domicílios com coleta de lixo adequada",
    prop_esgoto_adequado="Proporção de domicílios com Esgoto Adequado",
    IRRSM="Razão do Rendimento Nominal Médio sobre o Salário Mínimo", #verificcar esse pois nao achei bom
    porte_populacional = "Porte populacional",
    raca_predominante = "Raça predominante"
  ) %>%
  #fmt_number(columns = everything(), decimals = 2) %>% #nao ficou bom
  fmt_percent(
    columns = c(urbanizacao,
                proporcao_idosos,
                prop_chefes_mulheres,
                coleta_lixo,
                prop_esgoto_adequado
                ),
    decimals = 2
   )# %>%
  # fmt_number(
  #   columns = densidade_demografica,   # sua variável
  #   decimals = 2,
  #   suffixing = FALSE,
  #   pattern = "{x}  p/km²"
  # )
