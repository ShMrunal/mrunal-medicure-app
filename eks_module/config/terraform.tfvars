
aws_eks_cluster_config = {

      "EKS-cluster" = {

        eks_cluster_name         = "EKS-cluster"
        eks_subnet_ids = ["subnet-06b1ce7b1ab49eaf8", "subnet-06b1ce7b1ab49eaf8"]
        tags = {
             "Name" =  "EKS-cluster"
         }  
      }
}

eks_node_group_config = {

  "node1" = {

        eks_cluster_name         = "EKS-cluster"
        node_group_name          = "mynode"
        nodes_iam_role           = "eks-node-group-general1"
        node_subnet_ids          = ["subnet-06b1ce7b1ab49eaf8", "subnet-06b1ce7b1ab49eaf8"]

        tags = {
             "Name" =  "node1"
         } 
  }
}
