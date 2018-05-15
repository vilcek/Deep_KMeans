library(kernlab)
library(igraph)
library(KRLS)

createGraph <- function(dir) {
  g_file <- read.table(paste('./', dir, '/network.dat', sep=''))
  G <- graph.data.frame(g_file, directed=T)
  A <- get.adjacency(G)
  CM <- read.table(paste('./', dir, '/community.dat', sep=''))
  GT <- CM$V2
  names(GT) <- CM$V1
  return(list(G, A, GT))
}

runSpecCluster <- function(A, GT) {
  return(specc(as.matrix(A), centers=length(unique(GT))))
}

runDeepKMeans <- function(G, GT, l, n) {
  S <- similarity.jaccard(G)
  d <- degree(G,mode='all')
  D <- diag(1/d)
  X <- D %*% S
  for(layer in 1:l) {
    K <- kmeans(X, centers=dim(X)[1]/2, iter.max=i, nstart=n)
    X <- K$centers
  }
  return(kmeans(t(X), centers=length(unique(GT)), iter.max=i, nstart=n))
}

Graph <- createGraph('./data/200')
G <- Graph[[1]]
A <- Graph[[2]]
GT <- Graph[[3]]
l <- 3
i <- 100
n <- 100

set.seed(12345)
igraph.options(vertex.size=10)
SC <- runSpecCluster(A, GT)
cat('Spectral Clustering Accuracy:', compare(GT, SC[1:length(GT)], method='nmi'), '\n')
plot(create.communities(G, membership=SC[1:length(GT)]), as.undirected(G), layout=layout.kamada.kawai(as.undirected(G)))
DKM <- runDeepKMeans(G, GT, l, n)
cat('Deep K-Means Accuracy:', compare(GT, DKM$cluster, method='nmi'))
plot(create.communities(G, membership=DKM$cluster), as.undirected(G), layout=layout.kamada.kawai(as.undirected(G)))