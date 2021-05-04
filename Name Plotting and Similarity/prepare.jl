using Pkg
Pkg.add("ZipFile")
Pkg.add("SQLite")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("FileIO")
using ZipFile, SQLite, CSV, DataFrames, FileIO

# TODO: change these to ARGS[1] and ARGS[2] once I figure out how to use command line
zip = ARGS[1]
dbname = ARGS[2]

db = SQLite.DB(dbname)

r = ZipFile.Reader(zip)

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS names (year INTEGER, name TEXT, sex TEXT, num INTEGER)")

df = DataFrame()
myregex = r"yob....\.txt"
for i in r.files
    if (!isnothing(match(myregex, i.name)))
        df_temp = CSV.File(read(i); header=["name", "sex", "num"]) |> DataFrame
        insertcols!(df_temp, 1, :year => i.name[4:7])
        append!(df, df_temp)
    end
end


# load DataFrame into SQL db
names = df |> SQLite.load!(db, "names")
# println(first(df))

# close connections
close(r)
close(db)