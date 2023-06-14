## 3.Cas d’étude 03

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

Pour creuser plus en détail et comprendre l'impact réel de cette attaque potentielle, voici quelques étapes que vous pourriez envisager :

 1. Analyse des journaux du serveur web et de l'application : Vérifiez si l'attaque a été suivie d'autres activités suspectes. Y a-t-il eu d'autres tentatives d'injection SQL à partir de la même adresse IP ? Y a-t-il eu des erreurs inhabituelles retournées par le serveur ou l'application ?

 2. Vérification de la vulnérabilité : Examinez le code de l'application où l'entrée utilisateur est utilisée dans une requête SQL (comme dans l'URL de recherche). L'application est-elle vulnérable à l'injection SQL ? Si c'est le cas, cela indique un risque potentiel plus élevé.

 3. Analyse de la base de données : Si vous suspectez qu'une injection SQL a été réussie, vous devrez examiner votre base de données. Vérifiez s'il y a des modifications inhabituelles dans les données ou les schémas. Il peut être utile d'utiliser des outils spécifiques à la base de données pour cela, comme MySQL Workbench pour MySQL ou pgAdmin pour PostgreSQL.

 4. Analyse de l'activité réseau : Utilisez des outils de surveillance réseau pour voir s'il y a eu une activité réseau suspecte en provenance ou à destination de votre serveur. Cela pourrait inclure une quantité inhabituelle de trafic, des connexions à des heures inhabituelles, etc.

 5. Analyse des artefacts : Si vous suspectez qu'une attaque a réussi, vous pouvez également examiner les artefacts laissés par l'attaquant. Cela pourrait inclure des fichiers malveillants téléchargés sur votre serveur, des modifications des fichiers du système ou de l'application, des processus malveillants en cours d'exécution, etc.

 6. Analyse de l'incident : Si vous identifiez que l'attaque a été réussie, il sera important de comprendre comment l'attaquant a réussi à exploiter votre système, quels dommages ont été causés et comment prévenir de futurs incidents. Cela peut impliquer une analyse en profondeur de l'incident, potentiellement avec l'aide d'une équipe de réponse aux incidents ou d'un consultant en sécurité.

#### 3. Considérant que l’application est vulnérable à ce type d’attaque, propose plusieurs solutions techniques (complémentaires) à implémenter afin de corriger ce type de faille et renforcer l’application.
La correction d'une faille d'injection SQL et le renforcement d'une application pour prévenir ce type de vulnérabilité peuvent être abordés de plusieurs manières. Voici plusieurs solutions techniques que vous pourriez envisager :

**Paramétrage des requêtes SQL :** La meilleure façon de prévenir les attaques par injection SQL est de n'accepter que des paramètres SQL strictement contrôlés. Cela peut être réalisé en utilisant des requêtes SQL préparées ou paramétrées, des procédures stockées et en évitant la concaténation de chaînes pour construire les requêtes SQL.

**Validation des entrées :** Toutes les entrées des utilisateurs doivent être validées avant d'être utilisées dans une requête SQL. Cela peut inclure la vérification du type, de la longueur, du format et du contenu. Les données qui ne passent pas la validation ne doivent pas être acceptées.

**Échappement des entrées :** Si vous devez utiliser les entrées des utilisateurs dans vos requêtes SQL, assurez-vous qu'elles sont correctement échappées. Cela empêchera les caractères spéciaux d'affecter la syntaxe de votre requête SQL.

**Utilisation du principe du moindre privilège :** Les comptes de base de données utilisés par l'application ne doivent avoir que les privilèges minimales nécessaires pour fonctionner. Cela peut limiter les dégâts en cas d'injection SQL réussie.

**Utilisation d'un pare-feu d'application Web (WAF) :** Un WAF peut aider à bloquer les tentatives d'injection SQL en filtrant le trafic HTTP/HTTPS entrant à la recherche de tentatives d'injection SQL.

**Patchs et mises à jour régulières :** Assurez-vous que votre serveur de base de données et votre environnement d'application sont régulièrement mis à jour avec les derniers patchs de sécurité.

**Révision du code et tests de pénétration :** Réaliser des audits de code réguliers pour détecter d'éventuelles vulnérabilités et effectuer des tests de pénétration pour identifier les points faibles de l'application.

**Logging et surveillance :** Enfin, assurez-vous que vous disposez de journaux appropriés et de systèmes de surveillance pour détecter rapidement toute tentative d'injection SQL.