# kelpbio documentation style

How kelpbio's reader-facing text is written: roxygen, `_pkgdown.yml` descriptions, DESCRIPTION, README, and vignettes; specs and PR and commit text follow its principles and mechanics. kelpbiodata and kelpbioshiny build on this file. It follows the [tidyverse style guide](https://style.tidyverse.org/documentation.html) and [*R Packages*, "Function documentation"](https://r-pkgs.org/man.html), with kelpbio rules for vocabulary, units, and models. Argument naming and order are API conventions and live in CLAUDE.md.

## Principles

1. Write for a first-time reader. Each sentence tells the reader what the function does, what to pass, what comes back, or something they could get wrong. Nothing else.
2. Brevity over completeness. One fact, stated once, in its one home.
3. No rationale, history, mechanism, or comparison with alternatives, and no development or testing jargon (for example `snapshot-safe`, `load_all()`). Describe current behaviour only, never the discussion or design change behind it ("always", "now", "no longer", "is invented"). Design reasons go in code comments, `decisions/`, or a change's `design.md`.
4. Technical, concise, scientific register; third person, present tense; no "you" or "your" (including example comments). Spelling is -ise (summarise, standardised, modelled) with "centred".

## Topic structure

| Part | Rule |
|---|---|
| Title | Sentence case, no full stop, short. Says what the function does or yields, without repeating the function name or the words every topic in its family shares. Action functions: imperative verb ("Fit a Nereocystis weight model"). Extractors and data: noun phrase ("Posterior draws", "Simulated Nereocystis weight data"). Genus names capitalised, not italic. |
| Description | One sentence, at most two lines, phrased differently from the title: what the function does or yields. Action functions (fit, predict, plot, check, construct) use the imperative; extractors (`tidy()`, `glance()`, `fitted()`, `log_lik()`, `posterior_*()`, `kb_samples()`) a noun phrase. No return mechanics, argument lists, or caveats. Full italic binomial on first mention in the topic. A description of more than one paragraph takes an explicit `@description`. |
| `@details` | Explicit tag. Only behaviour a caller could get wrong: argument interactions, what a new level does, units. At most three short paragraphs; a bulleted list where items are parallel; markdown headings (`# Heading`) to split longer details. Fit topics: the model paragraph (see Model descriptions). |
| `@section` | Only for text shared between topics and inherited from `params.R`. |
| `@returns` | Required on every exported topic (`@returns`, not `@return`). The sole home of the return type and shape: class, length or dimensions, and for data frames the rows and added columns. Mention any warning or error a caller may see. |
| `@seealso` | The next step or the closest alternative. One link as a sentence ("[kb_new_data()] to build rows for curves."); several as a bulleted list. Do not repeat a link already in the text. |
| `@family` | Plural family names: `fit functions`, `priors`, `data checks`, `example datasets`, `example fits`, `prediction functions`, `diagnostics`, `fit methods`. The simulated datasets and pre-fit models have their own pkgdown section, "Example data and fits". |
| `@references` | Full reference with `\doi{}`; cite in text as "(Vehtari et al. 2021)". |
| `@examples` | See Examples. |

## Arguments

Shared text: any argument description used in two or more topics lives in `R/params.R` and is pulled in with `@inheritParams params`; a nereo/macro twin inherits from its twin. No argument text is copied by hand. Tightly coupled arguments are documented together (`@param lower,upper`).

Each description is a sentence: it starts with a capital and ends with a full stop. Lead with the chk type, then what the argument is. Do not restate a default the usage line shows; always say what `NULL` does, and explain any default whose effect is not obvious.

| Type | Wording |
|---|---|
| Fit object | "A `kb_fit_weight` object." (dispatch class; `kb_fit` for any fit) |
| Data frame | "A data frame of <what>, one row per <unit> (see [kb_check_data_x()] for the columns)." |
| `new_data` | "A data frame of the rows to predict at, with <columns>, or `NULL` for the observed data." |
| Flag | "A flag specifying whether to <verb>." |
| String choice | "A string, one of `"a"` (<meaning>) or `"b"` (<meaning>)." When each option needs a sentence, a bulleted list after "A string, one of:". |
| Character vector | "A character vector of <what>." |
| Whole number | "A whole number of <what>." / "A positive whole number of <what>." |
| Number | "A number between 0 and 1 giving <what>." / "A number greater than 0 giving <what>." |
| Function | "A function that <does what>, such as `median`." |
| List | "A named list of <what> (see [fun()])." |
| `NULL` option | "..., or `NULL` to <behaviour>." |
| `...` (empty) | Inherited from `params.R`: "These dots are for future extensions and must be empty." |
| `...` (passed on) | "Additional arguments passed to [pkg::fun()]." |

Units: give the unit once, in parentheses after the quantity, as a symbol: "(mm)", "(kg)", "(kg/m²)", "(g C/m²)", "(m)". Column names already carry the suffix, so do not restate units in words ("in millimetres").

## Return values

| Returns | Wording |
|---|---|
| Fit | "A `kb_fit_weight_nereo` object (a `kb_fit`)." |
| Predictions | "A `kb_predictions` object: `new_data` with added `estimate`, `lower`, and `upper` columns for the expected <quantity>." |
| Tibble | "A tibble with one row per <unit> and columns `a`, `b`, and `c`." |
| Validator | "`data`, invisibly." |
| Flag | "`TRUE` if <condition>, otherwise `FALSE`." |
| Plot | "A ggplot object." |
| Matrix | "A draws-by-observations matrix." |
| Side effect | "<Thing>, invisibly. Called for <effect>." |

## Vocabulary

One term per concept, used everywhere:

| Concept | Use | Not |
|---|---|---|
| A site in a year (data unit) | site-year | site by year |
| The interaction effect | site:year effect | site-year effect, site-by-year |
| Levels the model has data for | site in the fit | seen, known, conditioned on, resolved |
| Levels the model lacks | new site / new year | unseen, never saw, absent from the fit's data |
| Interval | compatibility interval; limits `lower`, `upper` | credible, confidence |
| Point summary | estimate (the posterior median by default) | point estimate (in prose) |
| Spread terms | standard deviation (SD after first use) | hyperparameter |
| Wet/dry | dry:wet ratio | wet-to-dry, dry:wet mass ratio |
| A count of plants over a searched area, by divers or from a boat or kayak | in situ survey (survey after first use in a topic) | dive survey, transect, field survey, ground truth |
| A map of a site's canopy from drone or other remote-sensing imagery | canopy map; the canopy imagery it is mapped from | drone survey, aerial survey, flight |
| Model inputs from the sub-models | combine | compose |

Model parameters are written exactly as `tidy()` reports them (`intercept`, `sd_site`, `logit_zero_inflation`). Any other symbol (such as `mu`, `alpha`, or `x`) is defined once where it first appears.

## Model descriptions (fit topics)

One paragraph, in this order: likelihood, linear predictor, group effects, notes a user could get wrong. Equations in code format using the reported parameter names and column names, for example `log(mu) = intercept + cover_slope * cover + site_effect + year_effect`. Define each non-parameter symbol once. No comparison with other forms; the default is the recommended option and the argument says what each option is.

## Examples

- Basic use first, then the most important variant: two or three calls at most. Examples are not tests; no edge cases.
- Use the bundled pre-fit objects and simulated datasets so examples run quickly without sampling.
- A call that fits a model goes under `@examplesIf interactive()`, after the `@examples` that use the pre-fit object (one topic can carry both).
- Comments are short headings, never "your" ("# At new rows, including a new site").
- Name prior arguments (`kb_prior_exponential(rate = 2)`).
- `set.seed()` only before a call whose result is random.
- Examples never error and never write outside `tempdir()`.

## Mechanics

- Markdown roxygen only; wrap at 80 characters; continuation lines of a tag indented two spaces.
- Links as `[fun()]` and `[pkg::fun()]`, on the first mention of a function in a topic only; other mentions in code font. No `\code{\link{}}`, and `\describe{}` only in `@format`.
- Code font for argument names, column names, values (`TRUE`, `FALSE`, `NA`, `NULL`, `...`), parameters, and class names. Package names are not in code font ("the posterior package"); a function or package name is not capitalised at the start of a sentence.
- Italics for genus and species; no bold in prose; no em or en dashes; "for example" rather than "e.g."; no hedging adverbs.
- Sentences under about 30 words; no nested parentheses.
- Every exported topic appears in `_pkgdown.yml` (`pkgdown::check_pkgdown()`).

## Templates for repeated topic types

- **Fit**: title "Fit a <Genus> <topic> model"; description "Fit a <topic> model for *Genus species*."; details = model paragraph (see Model descriptions); Sampling section inherited; returns "A `kb_fit_<topic>_<sp>` object (a `kb_fit`)."; examples = `tidy()` of the pre-fit, then the fit under `@examplesIf interactive()`.
- **Priors**: title "Default priors for the <Genus> <topic> model"; description "The default priors for the <topic> model. To change a prior, pass a list of the entries to change to `priors`; the other entries keep their defaults."; returns "A named list of prior objects with entries `a`, `b`, ..." with each entry's role; examples = print the defaults, then a fit with a one-entry list under `@examplesIf interactive()`.
- **Data check**: title "Check <Genus> <topic> data"; description "Check that `data` has the columns and values needed to fit the <topic> model."; details = required columns list, then "Other columns are ignored."; returns "`data`, invisibly."
- **Species pages that inherit**: where both species take the same data, checks, and default priors (wet/dry, carbon, nitrogen), each species keeps its own page with its own title, description, return class, and examples, and the Macrocystis page inherits the rest from the Nereocystis page: `@inherit kb_fit_<topic>_nereo details sections` with `@inheritParams kb_fit_<topic>_nereo` (its own `data` and `priors`, which link to its own functions), and `@inherit kb_<verb>_<topic>_nereo details return` for priors and data checks. Text shared by both species goes in the Nereocystis page's `@details`, not its description.
- **Prediction**: title "Predict <quantity>"; description "Predict the expected <quantity> (unit) at each row of `new_data`."; details = only species-specific behaviour; returns per Return values.
- **Dataset**: title "Simulated <Genus> <topic> data"; description one sentence on what a row is; `@format` items "<Definition> (<unit>)."
- **Pre-fit**: title "Example <Genus> <topic> fit"; description "A fit of [kb_fit_x()] to [data_x] with fewer draws than the default, for exploring the fit methods without running the sampler."; format "A `kb_fit_<topic>_<sp>` object."
