If the first cell provides an error, please follow the directions it outputs and import the necessary library using Pkg.

I chose to do PCA on every amount of features, from 1 to 26. The results were fed into a Decision Tree model from ScikitLearn and tested for accuracy.

Most results were around 40-50% accuracy, but there was a clear trend of higher accuracy when more dimensions were allowed, which makes sense. However, the accuracy plateaued around 7, meaning it may be more effective to use a number of features around 7 rather than all of them.

The accuracy is plotted against the number of dimensions, and later the time taken for PCA is plotted agains the dimensions as well. These plots should serve to accomplish task 5 in which one could identify the classifier error based on the number of features selected.