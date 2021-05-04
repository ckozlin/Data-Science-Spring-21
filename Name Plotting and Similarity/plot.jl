using Pkg
Pkg.add("SQLite")
Pkg.add("Gadfly")
Pkg.add("DataFrames")
using SQLite, Gadfly, DataFrames

dbname = ARGS[1]
nameInput = lowercase(ARGS[2])
sexInput = uppercase(ARGS[3])

db = SQLite.DB(dbname)

# use SQLite.execute to query database?
df = DBInterface.execute(db, "SELECT year, num
from names
where lower(name) = \"$nameInput\"
and sex = \"$sexInput\" 
order by year;") |> DataFrame

yGuide = ARGS[2]

p = plot(df, x=:year, y=:num, Geom.point,
    Guide.xlabel("Year"), Guide.ylabel("Babies ($sexInput) in US named $yGuide"))

img = SVG("$sexInput-$yGuide-plot.svg", 30cm, 16cm)
display(img, p)