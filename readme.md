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

## partie observabilité

à la fin de l'étape 2 de la partie observabilté (tous les copier coller) le ```terraform fmt``` pointers main.tf, mais bref peu importe, surtout le ```terraform validate``` me réponds ça :  
```
╷
│ Error: Unsupported attribute
│
│   on main.tf line 107, in module "observability":
│  107:   storage_account_id = module.storage.storage_account_id
│     ├────────────────
│     │ module.storage is object with 1 attribute "storage_account_name"
│
│ This object does not have an attribute named "storage_account_id".
╵
╷
│ Error: Reference to undeclared input variable
│
│   on modules\app-service\main.tf line 28, in resource "azurerm_linux_web_app" "app":
│   28:   app_settings = merge(var.app_settings, {
│
│ An input variable with the name "app_settings" has not been declared. This variable can be declared with a variable
│ "app_settings" {} block.
╵
╷
│ Error: Reference to undeclared input variable
│
│   on modules\function-app\main.tf line 41, in resource "azurerm_linux_function_app" "fn":
│   41:   app_settings = merge(var.app_settings, {
│
│ An input variable with the name "app_settings" has not been declared. This variable can be declared with a variable
│ "app_settings" {} block.
╵
╷
│ Error: Invalid resource type
│
│   on modules\observability\main.tf line 78, in resource "azurerm_application_insights_standard_availability_test" "app_health":
│   78: resource "azurerm_application_insights_standard_availability_test" "app_health" {
│
│ The provider hashicorp/azurerm does not support resource type
│ "azurerm_application_insights_standard_availability_test".
╵
╷
│ Error: Invalid resource type
│
│   on modules\observability\main.tf line 97, in resource "azurerm_application_insights_standard_availability_test" "func_health":
│   97: resource "azurerm_application_insights_standard_availability_test" "func_health" {
│
│ The provider hashicorp/azurerm does not support resource type
│ "azurerm_application_insights_standard_availability_test".
╵
```

donc je m'en occuperais plus tard 🙏