#' Calculates some information regarding the pathways
#'
#' @param pGraph  a GraphNEL object of a KEGG pathway
#' @param pathID  KEGG ID of an input pathway
#' @param deKIDs  list of differentially expressed genes
#' @param Name    the pathway name
#' @param allKIDs list of all genes with their associated KEGG IDs
#' @param keggRef list of reference genes from KEGG
#' @param iter    the number of iterations for causal disturbance
#' @param alpha   the dampening factor for Source/Sink Centrality
#' @param beta    the relative Source vs Sink factor
#' @param statEval Choose 1 for product-based, 0 for summation-based
#'
#'
#' @importFrom KEGGgraph    translateGeneID2KEGGID
#' @importFrom graph    nodes
#' @importFrom magrittr %>%
#'

processPathway <- function(pGraph,Name, deIDs, allIDs, iter,
                           alpha,beta,statEval) {

    deKIDs      <- KEGGgraph::translateGeneID2KEGGID(deIDs)
    allKIDs     <- KEGGgraph::translateGeneID2KEGGID(allIDs)

    tempNodes   <- nodes(pGraph) %in% allKIDs
    nodeNums    <- nodes(pGraph)[tempNodes]
    isDiffExp   <- nodes(pGraph) %in% deKIDs
    isDiff      <- sum(isDiffExp)
    deSize      <- length(deIDs)
    allSize     <- length(allIDs)
    totPath     <- sum(tempNodes)



    fTestRes        <- stats::phyper(isDiff - 1, totPath, allSize - totPath,
                                     deSize, lower.tail = F)
    disturbProb     <- pathSampler(pGraph, deKIDs, iter, alpha, beta, statEval)

    if(is.na(disturbProb)){
        causalDist <- fTestRes
    } else{
          causalDist <- stats::pchisq(-2 * sum(log(fTestRes), log(disturbProb)),
                                     df = 4, lower.tail = FALSE)
         }

    #cat("pathway done: ", Name,"\n")
    return(list(Name,graph::numNodes(pGraph),graph::numEdges(pGraph),fTestRes,
                isDiff, disturbProb, causalDist))

}
