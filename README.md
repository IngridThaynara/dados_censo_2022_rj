# Introdução

O Censo Demográfico 2022, conduzido pelo Instituto Brasileiro de Geografia e Estatística (IBGE), oferece um conjunto abrangente de informações populacionais, domiciliares, socioeconômicas e territoriais em nível de setor censitário. A partir desses dados, é possível construir indicadores sintéticos que auxiliem na compreensão das condições demográficas, sociais, econômicas e de infraestrutura dos municípios.

O objetivo deste relatório é apresentar a construção de **14 indicadores municipais para os 92 municípios do Estado do Rio de Janeiro**, utilizando exclusivamente os microdados agregados por setor disponibilizados pelo pacote **censobr**. Esses indicadores foram desenvolvidos a partir do processamento das bases de *Basico*, *Pessoas*, *Domicílio* e *Responsável pela Renda*, devidamente integradas e sumarizadas para o nível municipal.

Os indicadores aqui apresentados foram selecionados por sua relevância para diagnósticos territoriais e para o planejamento de políticas públicas, abrangendo dimensões como:

-   **estrutura demográfica** (densidade populacional, razão de dependência, proporção de idosos);

-   **configuração domiciliar e condições de vida** (tamanho médio dos domicílios, acesso à internet, coleta de lixo adequada, esgotamento sanitário);

-   **estrutura socioeconômica** (renda, escolaridade, segurança econômica);

-   **características familiares** (chefes mulheres, presença paterna).

Cada indicador é descrito com sua finalidade, interpretação, variáveis utilizadas e fórmula aplicada para o município $m$. Dessa forma, o relatório busca oferecer uma base transparente, reprodutível e metodologicamente consistente para análises municipais no contexto fluminense.

# Indicadores 

## Densidade Demográfica

A densidade demográfica indica o grau de concentração populacional no município $m$ e é útil para o planejamento urbano e análise de infraestrutura.

**Variáveis**

-   $\text{pop}_m = V0001_m$
-   $\text{area}_m = \text{area\\_km2}_m$

**Fórmula**

$$
\text{densidade\\_demografica}_m = 
\frac{\text{pop}_m}{\text{area}_m}
$$

------------------------------------------------------------------------

## Índice de Urbanização

O índice de urbanização mede a proporção de moradores em áreas urbanas no município $m$, sendo importante para estudos de mobilidade e serviços urbanos.

**Variáveis**

-   $\text{urb}_m = V0002_m$
-   $\text{pop}_m = V0001_m$

**Fórmula**

$$
\text{indice\\_de\\_urbanizacao}_m =
\frac{\text{urb}_m}{\text{pop}_m}
$$

------------------------------------------------------------------------

## Razão de Dependência

A razão de dependência expressa a relação entre a população dependente (0–14 e 65+) e a população em idade ativa (15–64) do município $m$.

**Variáveis**

-   $\text{pop0\\_14}_m = V01031_m + V01032_m + V01033_m$
-   $\text{pop15\\_64}_m = V01034_m + V01035_m + V01036_m + V01037_m + V01038_m$
-   $\text{pop65mais}_m = V01039_m + V01040_m + V01041_m$

**Fórmula**

$$
\text{razao\\_dependencia}_m =
\frac{\text{pop0\\_14}_m + \text{pop65mais}_m}{\text{pop15\\_64}_m}
$$

------------------------------------------------------------------------

## Proporção de Idosos (65+)

Indica a participação da população idosa (65 anos ou mais) do município $m$ em relação ao total da população.

**Variáveis**

-   $\text{idosos}_m = V01039_m + V01040_m + V01041_m$
-   $\text{pop}_m = V0001_m$

**Fórmula**

$$
\text{proporcao\\_idosos}_m =
\frac{\text{idosos}_m}{\text{pop}_m}
$$

------------------------------------------------------------------------

## Proporção de Chefes Mulheres

Mede a proporção de domicílios chefiados por mulheres no município $m$, importante para estudos de desigualdade e autonomia econômica.

**Variáveis**

-   $\text{chefesTotais}_m = V01062_m + V01063_m$
-   $\text{chefesMulheres}_m = V01063_m$

**Fórmula**

$$
\text{prop\\_chefes\\_mulheres}_m =
\frac{\text{chefesMulheres}_m}{\text{chefesTotais}_m}
$$

------------------------------------------------------------------------

## Filhos Sem Presença Paterna (PFSP)

Mostra a proporção de crianças e adolescentes sem presença paterna no município $m$, importante para estudo de vulnerabilidade familiar.

**Variáveis**

-   $\text{filhosSemPai}_m = V01045_m$
-   $\text{filhosTotais}_m =
    V01042_m + V01043_m + V01044_m + V01045_m +
    V01046_m + V01047_m + V01048_m + V01049_m + V01050_m$

**Fórmula**

$$
\text{pfsp}_m =
\frac{\text{filhosSemPai}_m}{\text{filhosTotais}_m}
$$

------------------------------------------------------------------------

## Tamanho Médio do Domicílio

Indica o número médio de moradores por domicílio no município $m$.

**Variáveis**

-   $\text{pop}_m = V0001_m$
-   $\text{domicilios}_m = \text{domicilio01\\_V00001}_m$

**Fórmula**

$$
\text{tamanho\\_medio\\_dom}_m =
\frac{\text{pop}_m}{\text{domicilios}_m}
$$

------------------------------------------------------------------------

## Proporção de Domicílios com Internet

Indica a proporção de domicílios com acesso à internet no município $m$, importante para análises de inclusão digital.

**Variáveis**

-   $\text{internet}_m =
    V00290_m + V00291_m + V00292_m + V00293_m +
    V00294_m + V00295_m + V00296_m + V00297_m +
    V00298_m + V00299_m + V00300_m + V00301_m +
    V00302_m + V00303_m + V00304_m + V00305_m$

-   $\text{domicilios}_m = \text{domicilio01\\_V00001}_m$

**Fórmula**

$$
\text{prop\\_internet}_m =
\frac{\text{internet}_m}{\text{domicilios}_m}
$$

------------------------------------------------------------------------

## Coleta de Lixo Adequada

Avalia a proporção de domicílios que possuem coleta de lixo adequada no município $m$.

**Variáveis**

-   $\text{lixoAdeq}_m = V00397_m + V00398_m$
-   $\text{lixoTotal}_m =
    V00397_m + V00398_m + V00399_m + V00400_m +
    V00401_m + V00402_m + V00403_m$

**Fórmula**

$$
\text{coleta\\_lixo}_m =
\frac{\text{lixoAdeq}_m}{\text{lixoTotal}_m}
$$

------------------------------------------------------------------------

## Proporção de Esgoto Adequado

Mostra a parcela de domicílios com esgotamento sanitário adequado no município $m$.

**Variáveis**

-   $\text{esgotoAdeq}_m = V00309_m$
-   $\text{esgotoTotal}_m =
    V00309_m + V00310_m + V00311_m + V00312_m +
    V00313_m + V00314_m + V00315_m + V00316_m$

**Fórmula**

$$
\text{prop\\_esgoto}_m =
\frac{\text{esgotoAdeq}_m}{\text{esgotoTotal}_m}
$$

------------------------------------------------------------------------

## Proporção de Renda Baixa

Indica a proporção da população com renda mais baixa no município $m$.

**Variáveis**

-   $\text{baixaRenda}_m = V06001_m + V06002_m$
-   $T_m = V06001_m + V06002_m + V06003_m + V06004_m + V06005_m$

**Fórmula**

$$
\text{renda\\_baixa}_m =
\frac{\text{baixaRenda}_m}{T_m}
$$

------------------------------------------------------------------------

## Índice de Segurança Econômica (ISE)

Expressa a razão entre população de baixa renda e de alta renda no município $m$, útil para medir desigualdade.

**Variáveis**

-   $BR_m = V06001_m + V06002_m$
-   $AR_m = V06004_m + V06005_m$

**Fórmula**

$$
\text{ise}_m =
\frac{BR_m}{AR_m}
$$

------------------------------------------------------------------------

## Índice de Escolaridade Superior Estimada (IESE)

Indica a proporção da população com ensino superior no município $m$, importante para medir desenvolvimento e capital humano.

**Variáveis**

-   $ES_m = V06004_m + V06005_m$
-   $T_m =
    V06001_m + V06002_m + V06003_m + V06004_m + V06005_m$

**Fórmula**

$$
\text{iese}_m =
\frac{ES_m}{T_m}
$$
