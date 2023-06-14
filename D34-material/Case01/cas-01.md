### 1. Quel outil a été utilisé pendant la phase de reconnaissance (scan) ?

192.168.199.2 - - [20/Jun/2021:12:36:26 +0300] "HEAD /bwapp/192.168.tar.lzma HTTP/1.1" 404 - "-" "Mozilla/5.00 (Nikto/2.1.6) (Evasions:None) (Test:sitefiles)"

HEAD /bwapp/... HTTP/1.1 est la requête elle-même. Une requête HEAD est une méthode qui demande une réponse identique à celle d'une requête GET, mais sans le corps de la réponse. C'est-à-dire, il demande seulement les en-têtes de réponse. Cela peut être utilisé pour récupérer les métadonnées d'un document ou vérifier si un document existe sans télécharger le document lui-même. Les chemins après le /bwapp/ sont les chemins d'accès que le demandeur essayait d'accéder. Cela semble indiquer une tentative d'accéder à des fichiers ou des répertoires potentiellement sensibles.

Dans l'ensemble, il semble que quelqu'un ait effectué un scan de sécurité ou une tentative de recherche de vulnérabilités sur votre serveur web en utilisant Nikto. 

### 2. Après la phase de reconnaissance, quelle technique a été utilisée pour découvrir la liste des répertoires accessibles sur le serveur web ? 
L'attaquant a utilisé un outil de scrapping pour extraire les informations des pages web.

### 3. Après la fin de la phase de découverte des répertoires, de quel type d'attaque l'application est-elle la cible ?

1. une attaque par brute force sur le serveur : directory listing (correspond à la phase de découverte).
2. une attaque par injection de code PHP.
3. une attaque par brute force sur le login pour se connecter
4. une attaque d'injection de commande pour vérifier le nom de l'utilisateur connecté:  
   192.168.199.2 - - [20/Jun/2021:12:52:36 +0300] "GET /bWAPP/phpi.php?message=%22%22;%20system(%27whoami%27) HTTP/1.1" 200 12778 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"
5. une attaque pour voir tous les utilisateurs:  
   192.168.199.2 - - [20/Jun/2021:12:52:46 +0300] "GET /bWAPP/phpi.php?message=%22%22;%20system(%27net%20user%27) HTTP/1.1" 200 13045 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"
6. une attaque qui affiche tous les partages de fichiers:  
   192.168.199.2 - - [20/Jun/2021:12:52:56 +0300] "GET /bWAPP/phpi.php?message=%22%22;%20system(%27net%20share%27) HTTP/1.1" 200 13175 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"
7. une attaque qui ajoute un nouvel utilisateur nommé "hacker" avec le mot de passe "Asd123":  
   192.168.199.2 - - [20/Jun/2021:12:53:23 +0300] "GET /bWAPP/phpi.php?message=%22%22;%20system(%27net%20user%20hacker%20Asd123!!%20/add%27) HTTP/1.1" 200 12755 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"

### 4. Cette dernière attaque a-t-elle fonctionné ou a-t-elle échoué ?
A la ligne 12548, on voit que le hacker accède au portail, il a donc réussi à se connecter:  
192.168.199.2 - - [20/Jun/2021:12:50:10 +0300] "GET /bWAPP/portal.php HTTP/1.1" 200 23369 "http://192.168.199.5/bWAPP/login.php" "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"

Il faudrait vérifier en base de donnée pour savoir si la dernière attaque qui tente d'ajouter un nouvel utilisateur nommé "hacker" avec le mot de passe "Asd123" a fonctionné.   
Sur le fichier des logs que le serveur a donné un code 200 à la requête.

### 5. Quel est le type de la quatrième attaque (son nom) et à quelle heure débute-t-elle ?
La quatrième attaque semble exploiter une vulnérabilité d'Injection de Code, spécifiquement une Injection de Commandes Shell.
Elle a lieu à 12:52:36 

### 6. Quelle est la charge malveillante (payload) utilisée en premier lors de la quatrième attaque ?
La charge malveillante est "%22%22;%20system(%27whoami%27)".  
Cette charge malveillante est URL encodée, si nous la décodons, elle donne : ""; system('whoami').
Cela signifie qu'après un vide ("";), la fonction system est utilisée pour exécuter la commande whoami sur le serveur.  
La commande whoami est une commande Unix qui renvoie le nom de l'utilisateur courant du système. Si le script phpi.php est vulnérable à l'injection de commandes et que la commande est exécutée, l'attaquant pourrait obtenir le nom de l'utilisateur courant du serveur, ce qui pourrait lui fournir des informations utiles pour des attaques ultérieures.

### 7. Y'a-t-il une trace démontrant la persistance de l'attaque ? si oui, quelle est la charge malveillante (payload) utilisée ?
Oui, lorsqu'il tente d'ajouter un utilisateur nommé "hacker" avec le mot de passe "Asd123".  
Le payload est "%22%22;%20system(%27net%20user%20hacker%20Asd123!!%20/add%27)".
Une fois décodée de son format URL encodé, la charge est ""; system('net user hacker Asd123!! /add').  
Cette charge malveillante tente d'utiliser la fonction system pour exécuter la commande net user hacker Asd123!! /add sur le serveur. Cette commande est une commande Windows qui crée un nouvel utilisateur sur le système avec le nom "hacker" et le mot de passe "Asd123!!". Si le script phpi.php est vulnérable à l'injection de commandes et que la commande est exécutée, l'attaquant pourrait créer un nouvel utilisateur sur le système, ce qui pourrait lui donner un accès supplémentaire au système.  

Si l'attaque a fonctionné on devrait voir ce nouvel utilisateur dans la base de données.

### 8. Quels sont les actions à entreprendre avant la remise en ligne de l’application ?
 1. Correction des vulnérabilités :  
La première étape consiste à corriger toutes les vulnérabilités connues qui ont été exploitées dans l'attaque. Cela peut impliquer la mise à jour de logiciels, la réparation de code personnalisé ou la modification des configurations de sécurité. Si possible, il est également recommandé d'effectuer un audit de sécurité complet pour découvrir et corriger toute autre vulnérabilité potentielle.

2. Nettoyage du système :  
Si l'attaquant a réussi à exécuter du code malveillant ou à créer des comptes d'utilisateur sur le système, il est nécessaire de nettoyer ces modifications. Cela peut impliquer la suppression de comptes d'utilisateur non autorisés, le nettoyage du code malveillant ou la restauration du système à partir d'une sauvegarde connue pour être sûre.

3. Analyse de l'incident :  
Il est important de comprendre comment l'attaque s'est produite et quelles étaient ses conséquences. Cela peut aider à prévenir des attaques similaires à l'avenir et à améliorer la réponse aux incidents. Cette analyse peut impliquer l'examen des journaux du système, l'analyse des payloads d'attaque et la consultation avec des experts en sécurité.

4. Amélioration de la surveillance et des défenses :  
Après une attaque, il peut être judicieux de renforcer la surveillance du système et les défenses de sécurité. Cela peut impliquer l'installation de systèmes de détection d'intrusion, l'amélioration des journaux et des alertes de sécurité, et la mise en œuvre de mesures de sécurité supplémentaires comme le pare-feu ou le système de prévention des intrusions.

5. Test de pénétration :  
Avant de remettre l'application en ligne, un test de pénétration devrait être effectué pour s'assurer que les vulnérabilités ont été correctement traitées et que l'application est sécurisée contre les futures attaques.