#!/bin/bash

# Les arguments d'entrée
chemin_zipdump="$1"
chemin_fichier_word="$2"

# Exécuter zipdump.py sur le fichier Word
output=$(python3 "$chemin_zipdump" "$chemin_fichier_word")

# Obtenir le nom du fichier sans le chemin
nom_fichier=$(basename "$chemin_fichier_word")

# Créer un nouveau dossier avec le nom du fichier
mkdir -p "./$nom_fichier"

# Lire chaque ligne de la sortie
echo "$output" | awk 'NR>1 {print $1, $2}' | while read -r file_index file_name; do
    # Vérifier si file_name est un fichier ou un répertoire
    if [[ $file_name == */ ]]; then
        # C'est un répertoire, donc on le crée
        mkdir -p "./$nom_fichier/$file_name"
    else
        # C'est un fichier, donc on l'extrait
        python3 "$chemin_zipdump" -s "$file_index" -d "$chemin_fichier_word" > "./$nom_fichier/$file_name"
        #echo "python3 $chemin_zipdump -s $file_index -d $chemin_fichier_word > ./$nom_fichier/$file_name"
    fi
done
