# Key DAX Measures

This document presents the main DAX measures used in the dashboard. The objective is to document the project's key business indicators while keeping the documentation concise and easy to navigate.

> [!NOTE]
> Only the primary business measures are documented here. Supporting and intermediate measures used exclusively in the calculation process have been intentionally omitted.

---

## Total Budget

Calculates the total investment budget allocated across all campaigns, considering only one record per offer.

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
-- Aporte Liberado Total = 
SUMX(
    VALUES(
        'Tranking Investimento'[offer_name]
    ),
    CALCULATE(
        MAX(
            'Tranking Investimento'[investment_limit]
        )
    )
)
```

</details>

---

## Budget Consumed

Calculates the amount of the allocated budget that has already been consumed.

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
-- Aporte Consumido Total = 
SUMX(
    VALUES(
        'Tranking Investimento'[offer_name]
    ),
    CALCULATE(
        MAX(
            'Tranking Investimento'[investment_used]
        )
    )
)
```

</details>

---

## Budget Consumption (%)

Calculates the percentage of the allocated budget that has been consumed.

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
-- % Consumo= 
VAR TabelaOfertas =
    SUMMARIZE(
        'Tranking Investimento',
        'Tranking Investimento'[offer_name],
    
        "Limite",
            CALCULATE(
                MAX(
                    'Tranking Investimento'[investment_limit]
                )
            ),
        "Utilizado",
            CALCULATE(
                MAX(
                    'Tranking Investimento'[investment_used]
                )
            )
    )

VAR LimiteTotal =
    SUMX(
        TabelaOfertas,
        [Limite]
    )

VAR UtilizadoTotal =
    SUMX(
        TabelaOfertas,
        [Utilizado]
    )

RETURN
    DIVIDE(
        UtilizadoTotal,
        LimiteTotal,
        BLANK()
    )
```

</details>

---

## Offer Status

Classifies each offer according to its budget consumption level.

| Budget Consumption | Status |
|-------------------:|--------|
| Blank | Sem Consumo |
| ≥ 89% | Desativada |
| ≥ 80% | Pausada |
| < 80% | Ativa |

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
-- Status da Oferta = 
VAR PercentualConsumo =
    [% Consumo]

RETURN
SWITCH(
    TRUE(),
    ISBLANK(PercentualConsumo), "Sem Consumo",
    PercentualConsumo >= 0.89, "Desativada",
    PercentualConsumo >= 0.80, "Pausada",
    "Ativa"
)
```

</details>

---

## Campaign Status

Determines the operational status of each campaign based on budget availability, consumption level, and the status of its associated offers.

| Business Rule | Status |
|---------------|--------|
| No campaign information available | Sem informação |
| All offers have no consumption | Sem Consumo |
| Budget opportunity is negative | Negociar Aporte |
| Budget is sufficient and all offers are active | Aporte OK |
| Budget is sufficient but inactive offers exist | Fazer Shift |
| Any other scenario | Revisar |

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
-- Status de Ação = 
VAR Oportunidade =
    [Oportunidade]

VAR Consumo =
    [% Consumo]

VAR QtdAtivas =
    [Qtd Ofertas Ativas Industria]

VAR QtdTotal =
    [Qtd Ofertas Industria]

VAR QtdSemConsumo =
    [Qtd Ofertas Sem Consumo Industria]

VAR TodasSemConsumo =
    QtdTotal > 0
        && QtdSemConsumo = QtdTotal

VAR TodasAtivas =
    QtdTotal > 0
        && QtdAtivas = QtdTotal

RETURN
SWITCH(
    TRUE(),

    QtdTotal = 0
        || ISBLANK(Oportunidade),
        "Sem informação",

    Consumo <= 0
        && TodasSemConsumo,
        "Sem Consumo",

    Oportunidade < 0,
        "Negociar Aporte",

    Oportunidade >= 0
        && TodasAtivas,
        "Aporte OK",

    Oportunidade >= 0
        && NOT(TodasAtivas),
        "Fazer Shift",

    "Revisar"
)
```

</details>

---

## Ideal Budget

Estimates the budget required to keep a campaign running until its end date based on the average daily consumption and the remaining campaign duration. The result may also indicate excess budget available for reallocation or the need for additional investment.

<details>
<summary><strong>View DAX Measure</strong></summary>

```DAX
Aporte Ideal= 
[Aporte Consumido Total] + ([Consumo Médio Diário Total] * [Dias Restantes da Campanha])
```

</details>
