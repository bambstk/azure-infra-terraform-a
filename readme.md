Salut c'est moi !

"4 bulldogs, tu sais que j'aurais 4 bulldogs" - Jolagreen23

le init marchait pas alors j'ai ajouté -backend=false pour skip la configurtion qui existait pas, source ?[tkt bro](https://developer.hashicorp.com/terraform/cli/commands/init#backend-initialization)

mais en fait mauvais bail pcq ça empeche le terraform plan de se lancer......
il suffit d'enlever le fichier backend.tf pour que ça marche sans encombre en fait (on le remettra plus tard si on en a besoin) 
(y avais aucun backend dans [leur tuto](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#initialize-your-terraform-configuration))

je l'ai remis plus tard pour pas avoir besoin de mettre 1Milliard d'argument sur le init mais il faut avoir fini le 6.2 pour que ça marche (créé le storage account et container ```az storage container create```)

dna sletape 6.2 c'est normal que la commande n'affiche rien apparement
mais celle là affiche ce qu'il faut :  
```az storage container list --account-name ststate8dvlp --auth-mode login --output table```


pour l'étape 8 il faut tout créer : 

```
az ad app create --display-name "github-actions-terraform-buambinho"
$AppId = (az ad app list --display-name "github-actions-terraform-buambinho" --query "[0].appId" -o tsv)
az ad sp create --id $AppId
```

mais je l'ai déjà fait donc :
```
$AppId = (az ad app list --display-name "github-actions-terraform-buambinho" --query "[0].appId" -o tsv)
az ad app federated-credential list --id $AppId --query "[].{Nom:name, Subject:subject}" --output table
```

sur powershell pour ajouter les authorisation sur l'app et son service principal il faut changer quelques trucs (là aussi je l'ai dejà fait, donc je le laisse juste pour l'historique 🙏):
```
$AppId --parameters @'
>> {    \"name\": \"github-azure-infra-terraform-a\", \"issuer\": \"https://token.actions.githubusercontent.com\", \"subject\": \"repo:bambstk/azure-infra-terraform-a:ref:refs/heads/main\",     \"audiences\": [\"api://AzureADTokenExchange\"]}
>> '@
```
et apparement pour la demande de poul c'est ça le texte : ```repo:bambstk/azure-infra-terraform-a:pull_request```

puis faut mettre l'app qui a le sp en contributor sur le RG (et pas oublier les permissions sur le yml de la gitlab ci(j'avais oublié....)) :  
``` az role assignment create --assignee 5538bd7b-b556-49dc-94a3-0442fbff0208 --role Contributor --scope /subscriptions/5e683e0f-b00c-48d6-9769-5aaf598de8f1/resourceGroups/lzniberRG```

bon en gros y a tflint  installé, et le précommit faut créer le fichier pre-commit dans .git/hooks, et mettre ça dedans :

```
#!/bin/sh

if cd ./terraform && tflint
then
    echo "tflint okidoki pas de probleme tu peux poush"
else
    echo "tflint pas content regarde le zin: "
    tflint
fi
```