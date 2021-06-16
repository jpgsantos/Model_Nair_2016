# SBtabVFGEN

Convert a Model written in [SBtab](https://www.sbtab.net/), saved as a
series of `tsv` files or alternatively an [Open Document
Spreadsheet](https://www.documentfoundation.org/) `ods` to a
[VFGEN](https://warrenweckesser.github.io/vfgen/) vector field file
`vf`.

As a byproduct, this script also produces a `mod` file intended as a
starting point for use in [neuron](https://neuron.yale.edu/neuron/).
If _libSBML_ is installed and R bindings available, an attempt will be
made to produce an SBML file (see further below).

The type of _systems biology_ models that we have in mind are
autonomous ordinary differential equations (ODEs), while _neuron_
comprehensively models biochemistry and electrophysiology (action
potentials etc.). These two different simulations have to be coupled
(in neuron), so the produced `mod` file is really only an initial
point; the user has to change the file and make it work inside of
neuron. The user must also be aware of NEURONs units and make the
necessary unit conversions.

Here is an example:
```R
tsv.files <- dir(pattern=".*[.]tsv");
source("sbtab_to_vfgen.R")
SBtabDoc <- sbtab_from_tsv(tsv.files)
Model <- sbtab_to_vfgen(SBtabDoc)
```
of the code in this repository, as it is used in R.

Alternatively, the document can be imported from `ods` using the
[readODS](https://cran.r-project.org/web/packages/readODS/index.html)
package:

```R
ods.file <- "examplemodel.ods" 
source("sbtab_to_vfgen.R")
SBtabDoc <- sbtab_from_ods(ods.file)
Model <- sbtab_to_vfgen(SBtabDoc)
```


## VFGEN

[VFGEN](https://github.com/WarrenWeckesser/vfgen) is a very useful
tool that can reformat an ODE (given in its custom `xml` format) and
convert it into various programming languages, including right hand
side functions for two ODE solvers in `C`:
[gsl](https://www.gnu.org/software/gsl/doc/html/ode-initval.html) and
[cvode](https://computing.llnl.gov/projects/sundials/cvode). While
doing so, it uses [GiNaC](https://ginac.de/) to calculate the model's
Jacobian analytically (among other things). The R script
`sbtab_to_vfgen.R` converts an SBtab model to vfgen's `xml` format.

Biological models don't necessarily map uniquely onto ODE models, a
compound can be a state variable or an algebraic assignment or a
constant, this has to be inferred a bit from the SBtab files.

## SBtab

[SBtab](https://www.sbtab.net/) is a tabular format for biochemical
models (as in Systems Biology). It is ~perhaps~ easier to understand
than `sbml` and can be parsed via shell scripts (e.g. with line
oriented tools such as `sed` and `awk`) due to its tabular nature
(e.g. tsv files).

We use this format mostly because it can be extended to contain
additional information more easily (such as experimental data, and
conditions under which data was measured).

To make a conversion feasible, we decided on a set of columns and
tables (some specified by `TableName` some also by `TableType`
according to the official specification) which have to be present for
the conversion to work.

In contrast to the official documentation, all tables must be kept in
their own `tsv` file, or different sheets of the same `ods` file. The
following Sections have more information on specific tables and their
required columns (in addition to the obvious `!ID` and `!Name`
columns).

All tables require a unique `!ID` column (the ID can be seen as a key
for associative arrays aka _dictionaries_ or _hash tables_). The
`!Name` column must be unique as well and the entries should work as
variable names in the language that you plan to convert the model
to. The script in this repository uses the `make.names()` function on
this column (which will make them unique, but break reactions) and
also replaces `.` with `_` in all names (dots are often illegal in
variable names, not in `R` though).

Many numbers can be given in a specified scale (like `log`), these
numbers will be converted to linear scale when a model file is written
to file. Let a quantity `y` be measured in unit `M` (y is a number
followed by a unit, y/m is just a number), and !Scale be set to
`log10`, then the number you write in the ![Default]Value column is
`z=log10(y/M)`. The script will do the inverse to generate the model and pass the unit on to `.mod` files.

No unit conversion is attempted here.

The names of all tables must be unique.

### Compound

This table defines the compounds that are supposed to be modeled bu
state variables and are subject to change by the reactions in the
systems. 

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !Scale | log, log10, linear | and some variants of these|
| !InitialValue | a number | (per unit) in the above scale |
| !Unit | the unit of the above number | as it would be in linear scale |
| !SteadyState | `TRUE` | this compound should reach a steady state in at least one scenario and you want to know whether this happened |
|              |`FALSE` | it is not important whether or not this compound reaches steady state|
| !Assignment| `Name` or `ID`| this field will assign a pre-defined algebraic expression to the compound|

The conversion script will make a file called
`[…]SuggestedOutput.tsv`, it will have lines that can be used to check
whether a compound has reached steady state (or not), this is done for
each compound that has `!SteadyState` marked as `TRUE`. If that output
is close to `0`, then steady state was reached (it's the sum of all
fluxes for the compound in question).

Others columns are unused but may be informative to the user, or others.

#### Compound Assignments

In some cases, a compound's amount or concentration is not supposed to
be governed by reactions (kinetic laws, stoichiometry) but rather by a
fixed (time-dependent) value. In SBML this is called a boundary
condition. If the species is supposed to be constant, the field
`!IsConstant` can be set to `TRUE`; otherwise, you can assign the
value of an expression, listed in the `Expression` table to this
compound. The `!Assignment` field can contain the name of an
`Expression`. In SBML, a rule will be created in the `listOfRules`,
that rule will target the boundary condition species:

```xml
      <species    id="PKC_active" 
                name="PKC_active_value" 
         compartment="Comp1" 
initialConcentration="0" 
      substanceUnits="substance" 
   boundaryCondition="true"/>
<!-- ......... -->
<!-- and later -->
<!-- ......... -->
      <assignmentRule variable="PKC_active">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <plus/>
            <ci> PKC_DAG_AA_p </ci>
            <ci> PKC_Ca_memb_p </ci>
            <ci> PKC_Ca_AA_p </ci>
            <ci> PKC_DAG_memb_p </ci>
            <ci> PKC_basal_p </ci>
            <ci> PKC_AA_p </ci>
          </apply>
        </math>
      </assignmentRule>

```

In the other formats, `vf` and `mod`, the relationship is much simpler:
```xml
<Expression Name="PKC_active_value" Description="defined expression Ex0" Formula="PKC_DAG_AA_p+PKC_Ca_memb_p+PKC_Ca_AA_p+PKC_DAG_memb_p+PKC_basal_p+PKC_AA_p"/>
<Expression Name="PKC_active" Description="defined expression S11" Formula="PKC_active_value"/>
```
which will lead to code such as:
```matlab
PKC_active_value = PKC_DAG_AA_p+PKC_Ca_memb_p+PKC_Ca_AA_p+PKC_DAG_memb_p+PKC_basal_p+PKC_AA_p;
PKC_active = PKC_active_value;
```

A blank value, `NONE`, `FALSE`, or `NO` means that there is no
Assignment for this species. Empty cells can be tricky if export or
import functions merge multiple delimiters (so `\t\t` is not
recognized as an empty cell).

A `TRUE` value in `!IsConstant` and meaningful assignments are
mutually exclusive and may lead to weird results.

### Parameters

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !Scale | `log`, `log10`, `linear` | some aliases of these are possible (such as `base-10 logarithm`)|
| !DefaultValue | a number | in above scale, normalized to the unit of measurement, possibly subject to fitting/sampling |
| !Std | a number | standard deviation / uncertainty of this parameter |
| !Min / !Max | numbers | respectively, used if !Std is not present |

The columns `!Std` and `!Min/Max` are only used in
sampling/optimization, the model conversion is unaffected by them, the
DefaultValue is passed on to the model files (if there is a place to
put them).

### Reactions

The column `!ReactionFormula` determines the stoichiometry of the
model, the `!KineticLaw` column determines the flux of the given
reaction. Both er required and are standard columns in SBtab.

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !KineticLaw | e.g. `kf*A*B-kr*AB` | the flux, as a math expression |
| !ReactionFormula | e.g. `A+B<=>AB` | so, `AB` will increase and both `A` and `B` will decrease by this reaction whenever the flux is positive |

Since the kinetic law determines the reversibility of the reaction, the
column `!IsReversible` is not necessary, but if you determine the
kinetics based on the law of mass action it may be important for you
to have that column as a reminder (for when you are auto generating
the `!KineticLaw` column, which this script doesn't do).

### Input

The input parameters to the model that distinguish different
experiments. These quantities are known and can be influenced by the
people who are performing an experiment (or rather the real
counterparts of these quantities can be influenced). These play the
roles of (additional) parameters, but a different kind of parameter
than in the Parameter table. Experiments are supposed to have the same
parameters of the normal kind and different parameters of the input
kind.

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !DefaultValue | number | same as with normal parameters, but these are set to known values during an _experiment_ (these have to be known values) |
| !ConservationLaw | `TRUE`| the parameter is the result of an earlier run of the conversion script|
||`FALSE` | this parameter is unrelated to conservation laws |

The `!ConservationLaw` column will eventually be obsolete and the
numbers in that column will be determined by the _experiment-specific_
initial conditions. Currently there is only one _initial condition_ vector for
_all_ experiments.

At this moment, a conservation law parameter will be ignored whenever
the script runs (again), because the script creates those itself (every time it runs).

### Output

The outputs are _observable quantities_ of this system; what is and
isn't an output depends on what you can measure (or have knowledge
about). Outputs are usually converted to functions in the target
language. _Experimental Data_ and _Outputs_ are intimately related as
the outputs are the model's equivalent of the data and in some way
those can be compared to one another.

It is possible to include the measured data in other sheets, that data should be
stored together with an estimate of the measurement noise
levels. Regardless of the nature of the noise and underlying
distributions we use `!ErrorName` to indicate which column (the one
that has this name) is storing information about this measurement
error.

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !ErrorName | a string | indicates the column in data sheets that hold the measurement error of an observable |
| !ErrorType | not used | this is for the user |
| !ProbDist  | a string | the probability distribution of the noise model (currently unused); this is for humans to read |
| !Formula   | a math expression | the right hand side of the assignment |

Many data columns may share the same Error column. This is useful if
you have only a very rough estimate of the noise anyway, and the
outputs are in the same number range so using the same standard
deviation (etc.) for all data points seems good enough.

The data sheets are not used by this script, but they are used [here](https://github.com/a-kramer/mcmc_clib).

### Expression

These will be local variables of the model. Expressions are
assignments that are calculated repeatedly each time the ODEs right
hand side is called (before fluxes are calculated, fluxes are otherwise also a
type of _expression_).

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !Formula | a math expression | right hand side of assignment|

Currently, there is no way to formally write something like _initial
assignments_, as those don't go into the model files, these
assignments have to happen before you call the model solver, so those
are up to you use of the model in the language you had in mind.

The only type of initial assignment that can be specified is the state
variables' initial conditions.

### Experiments

This table holds the mapping between input parameters and data
sheets. It determines the conditions under which a data set should be
replicated using the model.

| Column | Values  | Comment |
| -----: | :-----: | :------ |
| !Type | `Time␣Series` |  indicates that the data is a `t->output` mapping |
|       | `Dose␣Response` | data sheet is an input/output curve, i.e. `input->output` mapping |
| `>some_id` | a number | sets the input parameters for this experiment |
|!Event| a table name | the name of an event table that holds time instantaneous model state changes |

This is not used by this converter, but useful for parameter fitting
and interpretation of _the input_ and _output_ concepts.

### Remarks about `!ID`s and `!Name`s

A long term goal is that IDs can be used everywhere in the rest of the
document to reference the row in question (but it's not guaranteed
yet) and doesn't yet work in the kinetic law / Reaction Formulas
(names are used there). In reference headers `>ID`, the ID must be
used.

The experimental measurement data portion of the files is ignored for
model generation.

If an ID is not unique (but is in a different sheet), new entries from
the new sheet override old entries. IDs have to be unique inside the
same sheet. Generally, it doesn't make sense to have the same ID for two 
rows, other than to override a general entry by a more specific entry.

## Open Document Format, Gnumeric and Spreadsheets in General

Even though `.tsv` files are more fundamental types (have least amount
of prerequisites), `.ods` files keep all the sheets in one file and
are slightly more convenient. [Gnumeric](http://www.gnumeric.org/) is
a spreadsheet software that handles both `ods` and tsv files fairly
well (it also has its own format `.gnumeric`)

This `R` script can process such files directly, as mentioned, using
the
[readODS](https://cran.r-project.org/web/packages/readODS/index.html)
package, but you can also convert between spreadsheet formats like
`.ods`, `.gnumeric` and `.tsv` files using `ssconvert`, a part of
[gnumeric](http://www.gnumeric.org/). The shell scripts in this
repository are an example of ssconvert usage.

Other spreadsheet programs such as _google spreadsheets_ and _libre
office_ export to `tsv` _one sheet at a time_ (with no easy
workarounds) and lack an option to export all sheets into as many
files. Gnumeric's `ssconvert` command does.

### Remarks

Sometimes, spreadsheet software introduces Unicode characters such as
`−` ('MINUS SIGN' U+2212, in html «\&minus;»). They should be replaced
by the ascii character `-` ('HYPHEN-MINUS' U+002D). And similarly for
other Unicode characters, unless they appear in comments (or generally
unparsed content). Minus and Hyphen can look quite similar: `−-`
(depending on font), but hyphen is the character that programming
languages understand as subtraction.

You can check your files for non-ascii characters like this:
```bash
grep -P '[^[:ascii:]]' *.tsv
#OR
grep -n '[^a-z_A-Z[:digit:][:punct:][:space:]]' *.tsv
# automatic minus to hyphen replacement:
sed -i 's/−/-/g' *.tsv
```

The second option avoids the `-P` switch.

Neither `grep` nor `egrep` define the `[:ascii:]` character class
without the `-P` option: perl regular expressions.

Of course you can use [perl](https://www.perl.org/) directly, or
anything else that has regular expressions.

# Systems Biology Markup Language (SBML level 2 version 4)

The program `sbtab_to_vfgen.R` also produces an `.xml` file in the _Systems Biology Markup Language_ .
This is only done, if _libsbml_ is installed with `R` bindings, like this:

```bash
$ R CMD INSTALL libSBML_5.18.0.tar.gz
```

*REMARK*: I don't know how to do that on _MS Windows_ systems.

If this check: `if (require(libSBML))` succeeds, then the scripts attempts to make an sbml file.

## Units

SBML has support for units in all quantities. The units are specified using these 4 properties: `kind`, `scale`, `multiplier`, and `exponent` .
These unit attributes are interpreted like this: 

```
(multiplier * kind * 10^scale)^exponent
```
or, if you prefer: 
```
power(prod(multiplier,kind,power(10,scale)),exponent)
``` 

The `kind` can be any [SI](https://en.wikipedia.org/wiki/International_System_of_Units) base unit, e.g. `second`.
Other units can be derived using products of these base units, `liter/(nanomole millisecond)` is expressed as:

```
<unitDefinition id="liter_per_nanomole_millisecond">
 <listOfUnits>
  <unit kind="litre" exponent="1" scale="0" multiplier="1"/>
  <unit kind="mole" exponent="-1" scale="-9" multiplier="1"/>
  <unit kind="second" exponent="-1" scale="-3" multiplier="1"/>
 </listOfUnits>
</unitDefinition>

```

In _SBtab_ files, units are written in a human readable form (`!Unit`
column) and it is not always easy to interpret those units. The `R`
program in this repository attempts to read the units using a
regular expression with sub-groups. To make it somewhat doable, we have
additional rules on unit-strings:

1. Only SI base units are allowed for now
   - derived units such as `Newton` or `Hz` are not understood (liter is the only exception)
   - not all SI prefixes are understood, but the most common ones are (G,M,k,c,m,µ,n,p,f)
1. Only one slash is allowed (the slash has the lowest precedence)
   - `liter / mole second` is ok 
   - `1/((mole/liter) * second)` is not ok (because it has two slashes)
   - multiplication has higher precedence than division
1. All parentheses are ignored
   - `(mole/liter)^(-1)` is not interpreted correctly, because parentheses will be ignored
   - `liter/mole second` is the same as `liter/(mole second)`
   - `*` and `␣` are the same (blank space is interpreted as multiplication)
1. Powers cannot have spaces between base and exponent, the `^` is optional
   - `s^2` is ok
   - `s2` is ok and means the same thing
   - `kg m s^(-2)` is ok and the same as `kg m s^-2`
   - `kg m s-2` is also ok and means the same as `kg m s^-2`
   - `cm2` is ok and means square centimeters
   - `kg m s^( -2 )` is not ok (spaces)
1. The literal `1` is interpreted as: this quantity is dimensionless (in sbml this is actually called `dimensionless`)
   - a `1` in a unit will reappear in sbml, even if unnecessary
   - `1 m / 1 s` will have 4 entries in the sbml unit definition, with two unnecessary `dimensionless` units
   - `1/s` will be the same as `s^-1` in effect, but `1/s` will have an unnecessary `dimensionless` unit entry in the definition
   - no simplification of the unit is performed, so `meter/meter` is not simplified to `1`
1. long words can be used as well as abbreviations
   - `millisecond` is ok
   - `ms` is also ok
   - `msecond` (probably) also ok (but weird)
1. multipliers are always `1` (we don't have a system for
   multipliers). They are used to convert to and from non SI systems
   (imperial and so forth)
   - inches and feet are not multiples of powers of ten of SI base units.
   - `inches` are not parsed by the regular expression anyway (and we don't plan to ever support non SI units)
   - the only hope for _non SI_ units would be the _natural units_
1. The units that are not understood, but don't lead to a crash/error in the R code are interpreted as `1`
   - the user can then correct those definitions in the sbml file by hand (using a normal text editor [but please not notepad, treat yourself])

Because we use a quite simple regular expression to parse units, the base unit for mass is `g` (not `kg`, it's a bit of an exception in the SI world). Here is the regular expression, possibly not up to date:
```R
pat <- paste0("^(G|giga|M|mega|k|kilo|c|centi|m|milli|u|μ|micro|n|nano|p|pico|f|femto)?",
	          "(l|L|liter|litre|g|gram|mole?|s|second|m|meter|metre|K|kelvin|cd|candela|A|ampere)",
	          "\\^?([-+]?[0-9]+)?$")

```

   
### A list of perfectly fine units

Newton, Hertz and M are not parsed automatically, use the long form in column 2.

|meaning|suggested string| kind | scale | exponent |
|------:|:---------------|:----:|:-----:| :-------:|
|Newton| `kg m s-2` | `"gram"` | +3 | 1 |
||| `"metre"` | 1 | 1 |
||| `"second"` | 1 | -2 |
|nanomolarity (`nM`)| `nmol/l` | `"mole"` | -9 | 1 |
||| `"litre"` |  1 | -1 |
|kHz| `ms^-1`| `"second"` | -3 | -1 |

However, the units are not always interpreted right by importers (in other software).
Note that `kHz` is a bit unusual as Hertz is reciprocal to a base unit (second), so `kHz` is  `1000/s = 1/0.001 s = ms^-1`. 

## Final Remarks on LIBSBML

The libSBML R bindings are not documented and there is some guesswork
involved here. The code in the repository is not yet tested very
thoroughly, so some what cryptic errors may occur. Most recently we
have used the `.tsv` form of sbml, not direct `.ods` input.

[Here](libsbml.md) is a small (incomplete) list of libsbml functions
in R (that we used).
