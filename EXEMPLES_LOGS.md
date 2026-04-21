# 📊 EXEMPLESSSS DE LOGS - CHAQUE OPÉRATION CRUD

Voici les logs que vous verrez dans `flutter logs` pour chaque opération une fois les corrections appliquées.

---

## 📲 DÉMARRAGE DE L'APPLICATION

```
🟢 AppInitialization.initialize()
  📌 Putting StorageService
  📌 Putting ApiService
  📌 Putting AuthService
  ... tous les services
  ✅ Initialization complete
```

---

## 🔐 LOGIN

### Requête:
```
📤 REQUEST [POST] /auth/login
   Base URL: http://10.0.2.2/ismgl-api/api/v1
   Full URL: http://10.0.2.2/ismgl-api/api/v1/auth/login
   Headers: {Content-Type: application/json, Accept: application/json}
   Body: {email: admin@ismgl.cd, mot_de_passe: Admin@123}

📥 RESPONSE [200]
   Response: {success: true, data: {token: eyJ0eXAiOiJKV1..., user: {id: 1, nom: Admin, ...}}}

🟢 AuthController.login()
   ✅ Login successful: Super Admin
   📌 Token saved: eyJ0eXAiOiJKV1...
   📌 User saved: Super Admin
```

### Résultat:
```
✅ Utilisateur connecté
✅ Token stocké en local
✅ Navigation vers dashboard
```

---

## 📊 DASHBOARD

### Requête:
```
🟢 DashboardController.onInit()

📤 REQUEST [GET] /dashboard
   Full URL: http://10.0.2.2/ismgl-api/api/v1/dashboard
   Authorization: Bearer eyJ0eXAiOiJKV1...
   Headers: {Accept: application/json, Content-Type: application/json}

📥 RESPONSE [200]
   Response: {success: true, data: {statistiques: {total_etudiants_actifs: 450, ...}, ...}}

📥 DashboardController.load()
   ✅ Dashboard data loaded
   Statistiques: 450 étudiants, 420 inscriptions, 380 payées
   Montant: 258.3M attendu, 233.6M perçu
```

### Résultat:
```
✅ Dashboard affiche les statistiques
✅ Cartes remplies avec données réelles
```

---

## 👥 LISTE ÉTUDIANTS (READ)

### Requête initiale:
```
📥 EtudiantController.loadEtudiants()
   Page: 1
   Search: 
   Statut: null
   Sexe: null

📤 REQUEST [GET] /etudiants
   Full URL: http://10.0.2.2/ismgl-api/api/v1/etudiants
   Params: {page: 1, page_size: 20}
   Headers: {Authorization: Bearer eyJ0eXA..., Accept: application/json}

📥 RESPONSE [200]
   Response: {success: true, data: {items: [...20 étudiants...], pagination: {current_page: 1, total_items: 450, total_pages: 23, ...}}}

   Parsed items: 20
   ✅ Total items: 450, Pages: 23

🏗️ Building EtudiantsPage
🔄 Rebuilding list. isLoading: false
   Data count: 20
   
   📋 Building card for: Kabila Jean
   📋 Building card for: Tshisekedi Marie
   📋 Building card for: Mukendi Paul
   ... 17 autres cartes
```

### Résultat:
```
✅ 20 étudiants affichés
✅ Liste paginée (page 1/23)
✅ Tous les détails visibles (nom, email, statut, date naissance)
```

---

## 🔍 RECHERCHE (READ + FILTER)

### Requête:
```
🔍 Search: Jean

📥 EtudiantController.loadEtudiants()
   Page: 1
   Search: Jean
   Statut: null
   Sexe: null

📤 REQUEST [GET] /etudiants
   Full URL: http://10.0.2.2/ismgl-api/api/v1/etudiants
   Params: {page: 1, page_size: 20, search: Jean}

📥 RESPONSE [200]
   Response: {success: true, data: {items: [...2 étudiants...], pagination: {current_page: 1, total_items: 2, total_pages: 1, ...}}}

   Parsed items: 2
   ✅ Total items: 2, Pages: 1

🔄 Rebuilding list. isLoading: false
   Data count: 2
   
   📋 Building card for: Jean Kabila
   📋 Building card for: Jean-Claude Martin
```

### Résultat:
```
✅ 2 étudiants trouvés (au lieu de 450)
✅ Liste filtrée en temps réel
✅ Pagination correcte (1/1 page)
```

---

## 🏷️ FILTRER PAR STATUT

### Requête:
```
🏷️ Filter statut: Suspendu

📥 EtudiantController.loadEtudiants()
   Page: 1
   Search: 
   Statut: Suspendu

📤 REQUEST [GET] /etudiants
   Params: {page: 1, page_size: 20, statut: Suspendu}

📥 RESPONSE [200]
   Parsed items: 5
   ✅ Total items: 5, Pages: 1

🔄 Rebuilding list. isLoading: false
   Data count: 5
   
   📋 Building card for: Nkosi Albert (Suspendu)
   📋 Building card for: Dupont Michel (Suspendu)
   ... 3 autres
```

### Résultat:
```
✅ 5 étudiants affichés
✅ Tous ont le statut "Suspendu"
```

---

## ➕ CRÉER ÉTUDIANT (CREATE)

### Requête:
```
📤 EtudiantController.createEtudiant()
   Data: {nom: Dupont, prenom: Jean, email: jean@example.com, ...}

📤 REQUEST [POST] /etudiants
   Full URL: http://10.0.2.2/ismgl-api/api/v1/etudiants
   Authorization: Bearer eyJ0eXA...
   Content-Type: multipart/form-data
   Body: FormData(nom: Dupont, prenom: Jean, ..., photo_profil: File(...))

📥 RESPONSE [201]
   Response: {success: true, message: "Étudiant créé avec succès", data: {id_etudiant: 451, numero_etudiant: ETU2024000451, ...}}

   ✅ Étudiant créé avec succès

   📥 EtudiantController.loadEtudiants()  ← Auto-refresh
   Page: 1
   
   📤 REQUEST [GET] /etudiants
   Params: {page: 1, page_size: 20}
   
   📥 RESPONSE [200]
   Parsed items: 20
   ✅ Total items: 451, Pages: 23  ← Nombre augmenté de 450 à 451

🔄 Rebuilding list. isLoading: false
   Data count: 20
   
   📋 Building card for: Jean Dupont  ← NOUVEAU
   ... 19 autres
```

### Résultat:
```
✅ Nouvel étudiant créé (ID 451)
✅ Liste automatiquement rafraîchie
✅ Nouvel étudiant visible en première position
✅ Total étudiants: 450 → 451
✅ Mesage de succès affiché à l'utilisateur
```

---

## ✏️ MODIFIER STATUT (UPDATE)

### Requête:
```
🔄 Updating statut to: Suspendu

📤 EtudiantController.updateStatut(451, Suspendu)

📤 REQUEST [PATCH] /etudiants/451/statut
   Full URL: http://10.0.2.2/ismgl-api/api/v1/etudiants/451/statut
   Authorization: Bearer eyJ0eXA...
   Body: {statut: Suspendu}

📥 RESPONSE [200]
   Response: {success: true, data: {statut: Suspendu}}

   ✅ Statut mis à jour avec succès

   📥 EtudiantController.loadEtudiants()  ← Auto-refresh
   
   📤 REQUEST [GET] /etudiants
   📥 RESPONSE [200]
   Parsed items: 20

🔄 Rebuilding list. isLoading: false
   Data count: 20
   
   📋 Building card for: Jean Dupont
      Statut: Suspendu  ← CHANGÉ
```

### Résultat:
```
✅ Statut changé de "Actif" à "Suspendu"
✅ Liste automatiquement rafraîchie
✅ Changement visible immédiatement
✅ Message de succès affiché
```

---

## 📄 CRÉER INSCRIPTION (CREATE)

### Requête:
```
📤 InscriptionController.createInscription()
   Data: {id_etudiant: 451, id_filiere: 1, id_niveau: 1, id_annee_academique: 1, type_inscription: Nouvelle}

📤 REQUEST [POST] /inscriptions
   Full URL: http://10.0.2.2/ismgl-api/api/v1/inscriptions
   Authorization: Bearer eyJ0eXA...
   Body: {id_etudiant: 451, id_filiere: 1, ...}

📥 RESPONSE [201]
   Response: {success: true, data: {id_inscription: 420, numero_inscription: INS-2024-0420, ...}}

   ✅ Inscription créée avec succès

   📥 InscriptionController.loadInscriptions()  ← Auto-refresh
   
   📤 REQUEST [GET] /inscriptions
   📥 RESPONSE [200]
   Parsed items: 20
   ✅ Total items: 420, Pages: 21  ← Augmenté

🔄 Rebuilding list. isLoading: false
   Data count: 20
```

### Résultat:
```
✅ Nouvelle inscription créée (ID 420)
✅ Liste automatiquement rafraîchie
✅ Total inscriptions: 419 → 420
```

---

## 💰 CRÉER PAIEMENT (CREATE)

### Requête:
```
📤 PaiementController.createPaiement()
   Data: {id_inscription: 420, id_etudiant: 451, id_type_frais: 1, id_mode_paiement: 1, montant: 500000}

📤 REQUEST [POST] /paiements
   Full URL: http://10.0.2.2/ismgl-api/api/v1/paiements
   Authorization: Bearer eyJ0eXA...
   Body: {id_inscription: 420, montant: 500000, ...}

📥 RESPONSE [201]
   Response: {success: true, data: {id_paiement: 851, numero_paiement: PAY-2024-01-0851, ...}}

   ✅ Paiement enregistré avec succès
   🧾 Reçu généré: REC-2024-00851

   📥 PaiementController.loadPaiements()  ← Auto-refresh
   
   📤 REQUEST [GET] /paiements
   📥 RESPONSE [200]
   Parsed items: 20
   ✅ Total items: 850, Pages: 43  ← Augmenté

🔄 Rebuilding list. isLoading: false
   Data count: 20
```

### Résultat:
```
✅ Paiement créé (ID 851)
✅ Reçu généré (ID 851)
✅ Liste automatiquement rafraîchie
✅ Montant perçu augmente
✅ Taux de recouvrement augmente
```

---

## 🔄 RAFRAÎCHIR MANUELLEMENT (Pull-down refresh)

### Requête:
```
📥 EtudiantController.loadEtudiants(reset: true)
   Page: 1
   Search: 
   Statut: null

📤 REQUEST [GET] /etudiants
   Params: {page: 1, page_size: 20}

📥 RESPONSE [200]
   Parsed items: 20
   ✅ Total items: 451, Pages: 23  ← Nombre à jour

🔄 Rebuilding list. isLoading: false
   Data count: 20
```

### Résultat:
```
✅ Données synchronisées avec le serveur
✅ Aucune animation de chargement longue
✅ Tout à jour
```

---

## ❌ CAS D'ERREUR: TOKEN EXPIRÉ (401)

### Requête:
```
📤 REQUEST [GET] /etudiants
   Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...  ← EXPIRÉ

📥 RESPONSE [401]
   Response: {success: false, status_code: 401, message: "Token expiré"}

🔴 ERROR [401] /etudiants

⚠️ Token expiré, tentative refresh...

📤 REQUEST [POST] /auth/refresh
   Body: {refresh_token: a1b2c3d4e5f6...}

📥 RESPONSE [200]
   Response: {success: true, data: {token: NEW_TOKEN..., ...}}

   ✅ Token refreshed successfully

   📤 REQUEST [GET] /etudiants
   Authorization: Bearer NEW_TOKEN...

📥 RESPONSE [200]
   Response: {success: true, data: {...}}

   Parsed items: 20
   ✅ Total items: 451, Pages: 23
```

### Résultat:
```
✅ Refresh automatique du token
✅ Requête rejouée automatiquement
✅ Utilisateur ne remarque rien
✅ Données finalement affichées
```

---

## ❌ CAS D'ERREUR: CONNEXION IMPOSSIBLE

### Requête:
```
📤 REQUEST [GET] /etudiants
   Full URL: http://10.0.2.2/ismgl-api/api/v1/etudiants
   Authorization: Bearer eyJ0eXA...

🔴 ERROR [connectionError]
   Message: Unable to connect to server

   ⚠️ Timeout - Connection failed
   Status: 503
   
   ❌ Exception: Unable to connect to http://10.0.2.2/ismgl-api/api/v1/etudiants
```

### Résultat:
```
❌ Message d'erreur: "Impossible de se connecter au serveur"
✅ Logs clairs indiquent le problème (URL, connexion, etc.)
✅ Utilisateur sait qu'il y a un problème réseau
```

---

## ❌ CAS D'ERREUR: VALIDATION INCORRECTE

### Requête:
```
📤 EtudiantController.createEtudiant()
   Data: {nom: , prenom: Jean, email: invalid_email, ...}  ← DONNÉES INVALIDES

📤 REQUEST [POST] /etudiants
   Body: {nom: , prenom: Jean, email: invalid_email, ...}

📥 RESPONSE [422]
   Response: {
     success: false,
     status_code: 422,
     message: "Erreur de validation des données",
     data: {errors: {
       nom: "Le champ nom est requis",
       email: "Le champ email doit être une adresse email valide"
     }}
   }

   ❌ Erreur: Erreur de validation des données
```

### Résultat:
```
❌ Message d'erreur: "Erreur de validation des données"
✅ Détails clairs sur les champs en erreur (nom, email)
✅ Utilisateur peut corriger et réessayer
```

---

## 📊 RÉSUMÉ DES LOGS

Avec les corrections, vous verrez toujours:

```
✅ Chaque requête HTTP (📤 REQUEST)
✅ Chaque réponse API (📥 RESPONSE)
✅ Chaque action controller (EtudiantController.xxx)
✅ Chaque état UI (Building, Rebuilding)
✅ Chaque opération data (Parsed items, Total items)
✅ Chaque erreur avec contexte (❌ Error type, message)
```

**Cela rend le debugging trivial: il suffit de chercher le problème dans les logs!** 🎯

