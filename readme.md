Salut c'est moi !

"4 bulldogs, tu sais que j'aurais 4 bulldogs" - Jolagreen23

le init marchait pas alors j'ai ajouté -backend=false pour skip la configurtion qui existait pas, source ?[tkt bro](https://developer.hashicorp.com/terraform/cli/commands/init#backend-initialization)

mais en fait mauvais bail pcq ça empeche le terraform plan de se lancer......
il suffit d'enlever le fichier backend.tf pour que ça marche sans encombre en fait (on le remettra plus tard si on en a besoin) 
(y avais aucun backend dans leur tuto)

dna sletape 6.2 c'est normal que la commande n'affiche rien apparement
mais celle là affiche ce qu'il faut : az storage container list --account-name ststate8dvlp --auth-mode login --output table
