Use prepare.jl to turn names.zip, a zip file of the frequencies of names by gender in the US since 1880, into a fully functioning database (names.db) that can be used with the other two files. To make the database using this file, type the command "julia prepare.jl names.zip names.db".

Use plot.jl to make a plot of a name's popularity over team in the United States. This file requires name and gender arguments-- For example, if you want a plot of the name Cameron for Males, type the command "julia plot.jl names.db Cameron M".

Lasty, you can use similar.jl to find the most similar boy/girl pair (and then use plot to check my work!).