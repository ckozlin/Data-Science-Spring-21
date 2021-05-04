
using DataFrames, SQLite, LinearAlgebra

# Task 1
dbname = "names.db"
db = SQLite.DB(dbname)
println("\nBeginning to convert $dbname to DataFrame...\n")
df = DBInterface.execute(db, "SELECT * from names") |> DataFrame
println("Database converted to DataFrame successfully.\n")

# Task 2
df_M = filter(row -> row[:sex] == "M", df)
df_b = unique(df_M, [:name])
Nb = nrow(df_b)
df_F = filter(row -> row[:sex] == "F", df)
df_g = unique(df_F, [:name])
Ng = nrow(df_g)
df_y = unique(df, [:year])
Ny = nrow(df_y)

# Task 3
# i_b = index to boy name
# b_i = boy name to index
i_b = Dict(i => df_b[i, :name] for i = 1:Nb)
b_i = Dict(df_b[i, :name] => i for i = 1:Nb)

i_g = Dict(i => df_g[i, :name] for i = 1:Ng)
g_i = Dict(df_g[i, :name] => i for i = 1:Ng)

i_y = Dict(i => df_y[i, :year] for i = 1:Ny)
y_i = Dict(df_y[i, :year] => i for i = 1:Ny);

# Task 4
Fb = zeros(Float32, Nb, Ny)
Fg = zeros(Float32, Ng, Ny);

# Task 5
# Put the num for each name at each year (if not in that year leave as 0)
function fillMatrix(A, name_i, year_i, df)
    for i = 1:nrow(df)
        x = name_i[df[i, :name]]
        y = year_i[df[i, :year]]
        A[x, y] = df[i, :num]
    end
end

fillMatrix(Fb, b_i, y_i, df_M)
fillMatrix(Fg, g_i, y_i, df_F)
println("Matrices Fb and Fg have been filled with name frequencies.\n")

# Task 6
# record total number of babies born each year
Ty = zeros(Float32, Ny)

for i = 1:nrow(df)
    index = y_i[df[i, :year]]
    Ty[index] += df[i, :num]
end

# Task 7
# matrix Fb will now contain ratio of that point in Fb to the corresponding year
function probMatrix(A, n_rows, n_cols, totals)
    for i = 1:n_rows
        for j = 1:n_cols
            A[i,j] = 1.0 * A[i,j] / totals[j]
        end
    end
end

probMatrix(Fb, Nb, Ny, Ty)
probMatrix(Fg, Ng, Ny, Ty);
println("Matrices Fb and Fg have become Pb and Pg (probability), respectively\n")

# Task 8
# Normalize Fb row by row
for i = 1:Nb
    Fb[i, 1:end] = normalize(Fb[i, 1:end])
end

for i = 1:Ng
    Fg[i, 1:end] = normalize(Fg[i, 1:end])
end

println("Matrices Pb and Pg have beome Qb and Qg (normalized), respectively\n")


# Task 9
# find max cosine distance of every pair of vectors
# partition each matrix into 10
# multiply each fragment by transpose of another (parallelize) then scan for max
# there should be 100 smaller matrices made, keep track of max as we go.

function findMostSimilar(Fb, Fg, Nb, Ng)
    myMax = 0
    startB = 1
    for i = 1:10
        println("Starting partition round $i of 10\n")
        numNamesB = Nb ÷ 10
        if i == 10
            numNamesB = Nb - (numNamesB * 9)
        end

        endB = startB + numNamesB - 1
        tempB = @view Fb[startB:endB, :]

        # need to multiply tempB by every partition of TempG transpose
        startG = 1
        
        Threads.@threads for j = 1:10
            numNamesG = Ng ÷ 10
            if j == 10
                numNamesG = Ng - (numNamesG * 9)
            end
            endG = startG + numNamesG - 1
            tempG = @view Fg[startG:endG, :]
            # multiply by transpose
            tempMatrix = tempB * transpose(tempG)
            # find myMax of new matrix
            maxFunc = findmax(tempMatrix)
            maxNum = maxFunc[1]

            # if max is actually the max we have found so far, record its index
            if maxNum > myMax
                myMax = maxNum
                # find index as offset from actual matrix
                relMaxi_b = getindex(maxFunc[2], 1)
                global maxi_b = relMaxi_b + startB - 1

                relMaxi_g = getindex(maxFunc[2], 2)
                global maxi_g = relMaxi_g + startG - 1
            end
            # update startG
            startG = endG + 1
        end
        startB = endB + 1
    end

    boy = i_b[maxi_b]
    girl = i_g[maxi_g]

    println("$boy (M) and $girl (F) have the largest cosine similarity.\n")
end

threads = Threads.nthreads()
println("Starting partitioned multiplication on $threads thread(s).\n")
@time findMostSimilar(Fb, Fg, Nb, Ng)




