# Super Terraform feat Azure gang 3k

## IaC 

Toute l'infrastructure azure du tp CLI est ici sous forme de code hcl pour que le deploiement et la destruction puisse se faire automatiquement et être répliqué et modifié facilement.

## étapes

### initialisation

```terraform init``` pour init, le state est stocké dans un storage azure, tous les paramettres sont dans le backend.tf

### planification

```terraform fmt``` pour check le format et ```terraform validate``` pour valider la syntaxe de base.  
On peut lancer un ```tflint``` pour être sûr sûr aussi après.  
```terraform plan``` pour voir les changements si il y en a et les appliquer dans le state

### appliquer

```terraform apply``` pour appliquer les changement du ```plan``` (donc créer les ressources azure)

### détruire

```terraform destroy``` pour détruire toutes les ressources crées avec le tag ```managed_by : terraform``` de manière automatique

## CI avec github action

Avec le workflow ci.yml du repo les étapes du ```init``` jusqu'au ```plan``` sont réalisées automatiquement à chaque pull request (nécessite la connection à azure, fait ici en OIDC grace à une app d'entreprise et un service principal entra ID).  
Et une fois le merge fait sur main on peut ```apply``` ou ```destroy``` en lançant le workflow terraform-deploy.yml manuellement en fonction des résultats du plan et de ce que l'on veut faire.

## hook pre-commit

on a aussi ajouté un hook pre commit dans .git/hooks qui lance un ```tflint``` avant chaque commit en local, pour être sûr qu'on commit pas quelque chose de cassé.
