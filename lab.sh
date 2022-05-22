
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights

rg=aks-rg1
loc=eastus
az group create --name $rg --location $loc
az network vnet create \
    --name AKSVirtualNetwork \
    --resource-group $rg \
    --address-prefixes 10.150.0.0/16  \
    --location $loc


az network vnet subnet create \
    --resource-group $rg \
    --vnet-name AKSVirtualNetwork \
    --name AKSSubnet \
    --address-prefixes 10.150.20.0/24

az identity create \
    --name AKSIdentity \
    --resource-group $rg

identityId=$(az identity show \
    --name AKSIdentity \
    --resource-group $rg \
    --query id \
    --output tsv)
subnetId=$(az network vnet subnet list \
    --vnet-name AKSVirtualNetwork \
    --resource-group $rg \
    --query "[?name=='AKSSubnet'].id" \
    --output tsv)

az aks create \
    --name AKSCluster \
    --resource-group $rg \
    --location $loc \
    --network-plugin azure \
    --vnet-subnet-id $subnetId \
    --service-cidr 10.240.0.0/24 \
    --dns-service-ip 10.240.0.10 \
    --generate-ssh-keys \
    --enable-managed-identity \
    --assign-identity $identityId \
    --node-vm-size  Standard_F8s_v2 \
    --node-count 2

az aks nodepool list \
    --cluster-name AKSCluster \
    --resource-group $rg \
    --output table

az network vnet subnet list \
    --vnet-name AKSVirtualNetwork \
    --resource-group $rg \
    --query "[].ipConfigurations.length(@)" \
    --output table


az aks scale \
    --name AKSCluster \
    --resource-group learn-d9ca977d-34e5-4599-a285-3601fc479d8a \
    --node-count=4


az aks get-credentials --resource-group $rg --name AKSCluster
az aks install-cli
az aks get-credentials --resource-group $rg  --name AKSCluster
kubectl apply -f azure-vote.yaml
kubectl get service azure-vote-front --watch

az group delete --name $rg --yes --no-wait
