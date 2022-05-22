rg=rg-aks101
loc=eastus
az group create --name $rg --location $loc
publicSSHKey=$(cat /c/Users/devsyc/.ssh/id_rsa.pub)
#ssh-keygen -t rsa -b 4096
az deployment group create \
  --name aksDeployment \
  --resource-group $rg \
  --template-file aks.json\
  --parameters clusterName=aks101 agentCount=1 \
        agentVMSize=Standard_F8s_v2 \
        linuxAdminUsername=aks_user \
        sshRSAPublicKey="$publicSSHKey" \
        dnsPrefix=abcd