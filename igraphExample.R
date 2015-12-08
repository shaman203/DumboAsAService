library(igraph)
el=read.csv("edges") #read edgelist file (must have header, 3 columns, last called weight)
g=graph.data.frame(el,directed = FALSE)

#adj=get.adjacency(g,attr='weight') #attr='weight' makes sure that the weights are shown in the adjacency matrix.
#adj

groups <- fastgreedy.community(g) # and voila

groupAssigments <- cbind(groups$names, groups$membership, deparse.level = 0)
colnames(groupAssigments) <- c("vertex", "group")
write.csv(groupAssigments, file="blogGroups.csv")

#par(mar=c(1,1,1,1)) #plot stupidity rectifier
#plot(g,edge.width=E(g)$weight/2, vertex.size = 0)

groupAssigments <- read.csv("blogGroups.csv")
groupEdgeList <- cbind(groupAssigments[match(el[,1],groupAssigments[,2]),3],groupAssigments[match(el[,2],groupAssigments[,2]),3], el[,3])


groupedEdges <- aggregate(groupEdgeList[,3], list(groupEdgeList[,1],groupEdgeList[,2]), FUN=mean)
names(groupedEdges) <- c("V1", "V2", "weight")

#groupedEdges2 <- groupedEdges[groupedEdges[,1] < 12,]
g2 <- graph.data.frame(groupedEdges,directed = FALSE)

#remove solitary edges(  degree <= 2)

g2 <- simplify(g2)
ids <- degree(g2);
#g2 <- delete.edges(g2,E(g2)[names(ids[ids <= 2]) %--% names(ids[ids <= 2])])
g2 <- delete.vertices(g2, V(g2)[names(ids[ids == 0])])



plot(g2, edge.width=E(g2)$weight/2)


#Adj. matrix plot
library(dplyr)
library(ggplot2)

g <- g2

el=read.csv("edges") #read edgelist file (must have header, 3 columns, last called weight)
g=graph.data.frame(el,directed = FALSE)

V(g)$comm <- membership(fastgreedy.community(g))

V(g)$comm <- groupAssigments

node_list <- get.data.frame(g, what = "vertices")
edge_list <- get.data.frame(g, what = "edges") %>%
    inner_join(node_list %>% select(name, comm), by = c("from" = "name")) %>%
    inner_join(node_list %>% select(name, comm), by = c("to" = "name")) %>%
    mutate(group = ifelse(comm.x == comm.y, comm.x, NA) %>% factor())

all_nodes <- sort(node_list$name)

# Adjust the 'to' and 'from' factor levels so they are equal
# to this complete list of node names
plot_data <- edge_list %>% mutate(
    to = factor(to, levels = all_nodes),
    from = factor(from, levels = all_nodes))

# Create the adjacency matrix plot
ggplot(plot_data, aes(x = from, y = to, fill = group)) +
    geom_raster() +
    theme_bw() +
    # Because we need the x and y axis to display every node,
    # not just the nodes that have connections to each other,
    # make sure that ggplot does not drop unused factor levels
    scale_x_discrete(drop = FALSE) +
    scale_y_discrete(drop = FALSE) +
    theme(
        # Rotate the x-axis lables so they are legible
        axis.text.x = element_text(angle = 270, hjust = 0),
        # Force the plot into a square aspect ratio
        aspect.ratio = 1,
        # Hide the legend (optional)
        legend.position = "none")


library(devtools)

# you need igraph:
install.packages("igraph")
library(igraph)

# install and load 'RBioFabric' from GitHub
install_github('RBioFabric',  username='wjrl')
library(RBioFabric)

#
# This is the example provided in the question:
#


# Plot it up! For best results, make the PDF in the same
# aspect ratio as the network, though a little extra height
# covers the top labels. Given the size of the network,
# a PDF width of 100 gives us good resolution.

height <- vcount(g)
width <- ecount(g)
aspect <- height / width;
plotWidth <- 100.0
plotHeight <- plotWidth * (aspect * 1.2)
pdf("myBioFabricOutput.pdf", width=plotWidth, height=plotHeight)
bioFabric(g)
dev.off()