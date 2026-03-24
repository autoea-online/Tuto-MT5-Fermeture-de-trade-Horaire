## 😎 La flemme de coder ?

Si vous avez la flemme d'être développeur et que vous voulez un **Expert Advisor personnalisé** sans écrire une seule ligne de code, venez voir notre générateur en ligne :

### 👉 [**EA Creator — Créez votre EA en 2 minutes**](https://autoea.online/generate) 👈

- ✅ Aucune compétence en programmation requise
- ✅ Configurez visuellement vos modules (SL, TP, TP Partiel, Break Even, Trailing Stop, Max Drawdown, **Fermeture Horaire**...)
- ✅ Fichier `.ex5` compilé et livré par email en 5 minutes
- ✅ Compatible toutes les Prop Firms
- ✅ Lié à votre compte MT5 pour plus de sécurité

> 🌐 **Site web :** [https://autoea.online](https://autoea.online)
>
> 📧 **Contact :** snowfallsys@proton.me


# ⏰ Tutoriel MT5 — Fermeture Horaire Automatique (Clôture à Heure Fixe)

[![MetaTrader 5](https://img.shields.io/badge/MetaTrader_5-Expert_Advisor-blue?style=for-the-badge&logo=metatrader5)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/MQL5-Language-orange?style=for-the-badge)](https://www.mql5.com/fr/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> **Tutoriel complet et détaillé** pour créer un Expert Advisor MQL5 qui **ferme automatiquement toutes les positions** à une heure précise chaque jour. Idéal pour le **day trading pur**, éviter les **swaps** et respecter les règles des **Prop Firms**. Chaque ligne de code est expliquée en français.

---

## 📖 Table des matières

1. [Introduction](#-introduction)
2. [Prérequis](#-prérequis)
3. [Architecture du projet](#-architecture-du-projet)
4. [Installation](#-installation)
5. [Explication complète du code](#-explication-complète-du-code)
   - [Fichier principal — FermetureHoraireBot.mq5](#1-fichier-principal--fermeturehorairebotmq5)
   - [Sélection des trades — TradeSelector.mqh](#2-sélection-des-trades--tradeselectormqh)
   - [Logique de temps — TimeCalculator.mqh](#3-logique-de-temps--timecalculatormqh)
   - [Fermeture des positions — TradeManager.mqh](#4-fermeture-des-positions--trademanagermqh)
6. [Comment fonctionne la Fermeture Horaire ?](#-comment-fonctionne-la-fermeture-horaire-)
7. [Heure broker vs heure locale](#-heure-broker-vs-heure-locale)
8. [Pourquoi éviter le overnight ?](#-pourquoi-éviter-le-overnight-)
9. [Prop Firms et horaires de trading](#-prop-firms-et-horaires-de-trading)
10. [Configuration et paramètres](#-configuration-et-paramètres)
11. [Gestion des erreurs](#-gestion-des-erreurs)
12. [Tests et backtest](#-tests-et-backtest)
13. [FAQ](#-faq)
14. [Liens utiles](#-liens-utiles)

---

## 🌟 Introduction

### Qu'est-ce que la Fermeture Horaire ?

La **Fermeture Horaire** est un mécanisme qui clôture automatiquement toutes vos positions ouvertes à une heure précise. C'est le "couvre-feu" du trading : quand l'heure arrive, tout est fermé, sans discussion.

### Pourquoi c'est utile ?

```
Scénario du day trader fatigué (vendredi 17h50) :

  "J'ai encore 3 positions ouvertes..."
  "Le marché va bientôt fermer..."
  "Je vais les laisser jusqu'à lundi..."    ← ERREUR !

  Résultat lundi matin :
  - Gap d'ouverture de -50 pips 📉
  - Swap de nuit × 2 jours = -$30 💸
  - Week-end de stress 😰

  Total : une mauvaise décision qui coûte cher.
```

```
Même scénario AVEC Fermeture Horaire (17h00) :

  17h00 : ⏰ L'EA ferme TOUT automatiquement
  Résultat : positions fermées au prix du marché
  Week-end : tranquille, pas de positions ouvertes ✅
```

### Les 5 raisons d'utiliser la Fermeture Horaire

| # | Raison | Détail |
|:-:|:---|:---|
| 1 | **Day trading pur** | Pas de positions overnight = stratégie propre |
| 2 | **Éviter les swaps** | Frais nocturnes qui grignotent les profits |
| 3 | **Prop Firms** | Certaines interdisent le trading overnight |
| 4 | **Anti-gap** | Les gaps du lundi matin sont imprévisibles |
| 5 | **Discipline** | L'EA force la clôture, pas d'excuses possibles |

---

## 🔧 Prérequis

- **MetaTrader 5** installé ([télécharger ici](https://www.metatrader5.com/fr/download))
- **MetaEditor** (inclus dans MT5)
- Un **compte de trading** (démo ou réel)

### Tutoriels de la série

| # | Tutoriel | Concept | Lien |
|:-:|:---|:---|:---:|
| 1 | Stop Loss Automatique | Protection initiale | [GitHub](https://github.com/autoea-online/Tuto-MT5-Stop-Loss-Automatique) |
| 2 | Take Profit Automatique | Objectif de gain | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique) |
| 3 | TP Partiel Automatique | Sécuriser une partie | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique) |
| 4 | Trailing Stop Automatique | SL suiveur | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Trailing-Stop-Automatique) |
| 5 | Break Even Automatique | Risque zéro | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Break-Even-Automatique) |
| 6 | Max Drawdown Daily | Protection du compte | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Max-Drawdown-Daily) |
| **7** | **Fermeture Horaire** | **Clôture automatique** | **Vous êtes ici** |

---

## 📁 Architecture du projet

```
📂 Tuto-MT5-Fermeture-Horaire/
│
├── 📂 Experts/
│   └── 📄 FermetureHoraireBot.mq5       ← Fichier principal de l'EA
│
├── 📂 Include/
│   ├── 📄 TradeSelector.mqh             ← Sélection des positions
│   ├── 📄 TimeCalculator.mqh            ← Logique de temps broker
│   └── 📄 TradeManager.mqh              ← Fermeture des positions
│
├── 📄 README.md                         ← Ce fichier
└── 📄 LICENSE                           ← Licence MIT
```

---

## 📥 Installation

### Méthode 1 : Installation manuelle

1. **Ouvrez MetaTrader 5**

2. **Accédez au dossier de données :**
   - Menu `Fichier` → `Ouvrir le dossier des données`

3. **Copiez les fichiers :**
   ```
   FermetureHoraireBot.mq5  →  MQL5/Experts/FermetureHoraireBot.mq5
   TradeSelector.mqh        →  MQL5/Include/TradeSelector.mqh
   TimeCalculator.mqh       →  MQL5/Include/TimeCalculator.mqh
   TradeManager.mqh         →  MQL5/Include/TradeManager.mqh
   ```

4. **Compilez dans MetaEditor :**
   - Ouvrez `FermetureHoraireBot.mq5` et appuyez sur `F7`

5. **Lancez l'EA :**
   - Glissez `FermetureHoraireBot` sur un graphique
   - Configurez l'heure et les minutes
   - Cliquez sur `OK`

### Méthode 2 : Clone Git

```bash
git clone https://github.com/VOTRE_USER/Tuto-MT5-Fermeture-Horaire.git
```

---

## 📝 Explication complète du code

### 1. Fichier principal — `FermetureHoraireBot.mq5`

#### Les paramètres d'entrée

```mql5
input int Heure_Fermeture = 17;                       // Heure (0-23)
input int Minute_Fermeture = 0;                        // Minute (0-59)
input bool Symbole_Courant_Seulement = false;          // Ce symbole uniquement ?
```

**Trois paramètres :**

| Paramètre | Rôle | Exemple |
|:-:|:---|:---:|
| `Heure_Fermeture` | À quelle heure fermer (broker) | 17 |
| `Minute_Fermeture` | À quelle minute | 30 |
| `Symbole_Courant_Seulement` | Fermer tout ou juste ce symbole | false |

#### Le flag anti-doublon

```mql5
bool DejaFermeAujourdhui = false;
```

Sans ce flag, l'EA essaierait de fermer à **chaque tick** pendant toute la minute 17:00 (potentiellement des centaines de fois). Le flag assure que la fermeture n'a lieu qu'**une seule fois**.

#### `OnTick()` — Logique de la fermeture

```
┌────────────────────────────────────────────┐
│           Nouveau tick reçu                 │
└──────────────────┬─────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────┐
│  1. Nouveau jour ?                          │
│     → OUI : réinitialiser le flag           │
│     → NON : continuer                       │
│                                             │
│  2. Déjà fermé aujourd'hui ?                │
│     → OUI : STOP                            │
│     → NON : continuer                       │
│                                             │
│  3. L'heure est-elle atteinte ?             │
│     → NON : on attend                       │
│     → OUI : 🚨                              │
│                                             │
│  4. Fermer les positions                    │
│     (toutes ou symbole courant)             │
│                                             │
│  5. Marquer comme exécuté (flag = true)     │
└────────────────────────────────────────────┘
```

---

### 2. Sélection des trades — `TradeSelector.mqh`

Deux fonctions de comptage :
- `CompterPositionsOuvertes()` : TOUTES les positions (quand `Symbole_Courant_Seulement = false`)
- `CompterPositionsSymbole()` : Seulement le symbole du graphique

---

### 3. Logique de temps — `TimeCalculator.mqh`

#### `EstHeureDeFermer()` — La comparaison temporelle

```mql5
bool EstHeureDeFermer(int heure, int minute)
{
    datetime maintenant = TimeCurrent();
    MqlDateTime tempsDecompose;
    TimeToStruct(maintenant, tempsDecompose);

    int minutesTotalesActuelles = tempsDecompose.hour * 60 + tempsDecompose.min;
    int minutesTotalesFermeture = heure * 60 + minute;

    return (minutesTotalesActuelles >= minutesTotalesFermeture);
}
```

**Pourquoi les "minutes totales" ?**

Comparer `heure >= heureFermeture` ne suffit pas :
```
Heure de fermeture = 17:30
Heure actuelle     = 17:15

17 >= 17 → VRAI (mais on n'est qu'à 17:15, pas 17:30 !)
17×60+15 = 1035 >= 17×60+30 = 1050 → FAUX ✅
```

#### Sources de temps en MQL5

| Fonction | Source | Usage |
|:---:|:---|:---|
| `TimeCurrent()` | Heure du dernier tick (broker) | ✅ **Recommandé** |
| `TimeLocal()` | Heure de votre PC | ❌ Variable selon le PC |
| `TimeTradeServer()` | Heure du serveur | Alternatif |

---

### 4. Fermeture des positions — `TradeManager.mqh`

Deux fonctions de fermeture :

| Fonction | Scope | Utilisée quand |
|:-:|:---|:---|
| `FermerToutesPositions()` | Tous les symboles | `Symbole_Courant_Seulement = false` |
| `FermerPositionsSymbole()` | Symbole courant | `Symbole_Courant_Seulement = true` |

Les deux utilisent la **boucle inversée** (voir le tutoriel Max Drawdown pour l'explication détaillée).

---

## 🎯 Comment fonctionne la Fermeture Horaire ?

### Chronologie d'une journée

```
╔═══════════════════════════════════════════════════════════╗
║              JOURNÉE DE TRADING                           ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  08:00  Début du trading                                  ║
║  │      EA actif, flag = false                            ║
║  │      ⏰ Fermeture programmée à 17:00                   ║
║  │                                                        ║
║  09:30  Position 1 ouverte (EURUSD BUY)                   ║
║  11:00  Position 2 ouverte (GBPUSD SELL)                  ║
║  14:30  Position 3 ouverte (USDJPY BUY)                   ║
║  │                                                        ║
║  16:59  3 positions ouvertes, heure < 17:00               ║
║  │      → L'EA ne fait rien                               ║
║  │                                                        ║
║  17:00  ⏰ HEURE ATTEINTE !                               ║
║  │      → Ferme Position 3, 2, 1 (ordre inversé)          ║
║  │      → Flag = true                                      ║
║  │                                                        ║
║  17:01  Nouveau tick arrive                                ║
║  │      → Flag = true → L'EA ne fait rien                 ║
║  │                                                        ║
║  00:00  📅 NOUVEAU JOUR                                   ║
║  │      → Flag = false (réinitialisé)                     ║
║  │      → Prêt pour la prochaine fermeture à 17:00         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🌍 Heure broker vs heure locale

### Le piège le plus courant

```
Votre heure locale : Paris (GMT+1 en hiver, GMT+2 en été)
Heure du broker    : GMT+2 (couramment utilisé)

Vous voulez fermer à 17:00 HEURE DE PARIS :
  Hiver : 17:00 Paris = 18:00 broker → configurez 18
  Été   : 17:00 Paris = 17:00 broker → configurez 17

⚠️ Si vous ne tenez pas compte du décalage,
   vous fermerez 1 heure trop tôt ou trop tard !
```

### Comment trouver l'heure de votre broker

1. Dans MT5, regardez l'heure affichée sur le graphique (coin inférieur droit)
2. Comparez avec votre heure locale
3. Notez le décalage (ex : broker +1h par rapport à Paris)
4. Configurez l'EA en **heure broker**

### Tableau de conversion courant

| Vous êtes en... | Fermeture souhaitée | Broker GMT+2 | Broker GMT+3 |
|:---:|:---:|:---:|:---:|
| Paris (GMT+1 hiver) | 17:00 local | Input = 18 | Input = 19 |
| Paris (GMT+2 été) | 17:00 local | Input = 17 | Input = 18 |
| Londres (GMT+0 hiver) | 17:00 local | Input = 19 | Input = 20 |
| New York (GMT-5) | 16:00 local | Input = 23 | Input = 0 |

---

## 🌙 Pourquoi éviter le overnight ?

### Les risques du overnight

| Risque | Impact | Fréquence |
|:---:|:---|:---:|
| **Swap** | Frais nocturnes (-$1 à -$20/lot) | Chaque nuit |
| **Gap** | Saut de prix à l'ouverture du marché | Chaque lundi |
| **News nuit** | Annonces économiques hors session | Variable |
| **Flash crash** | Chute brutale en liquidité faible | Rare mais dévastateur |

### Le coût des swaps

```
Position BUY EURUSD, 1 lot standard :
  Swap négatif = environ -$6/nuit
  
  1 semaine (5 nuits) = -$30
  1 mois (22 nuits) = -$132
  1 an = -$1,584 💸

  C'est de l'argent qui disparaît SANS que vous tradiez !
```

### Les gaps du lundi matin

```
Vendredi soir : EURUSD = 1.10000 (vous avez un BUY)
                SL = 1.09700 (-30 pips)

Lundi matin   : EURUSD ouvre à 1.09500 ⚡
                Votre SL à 1.09700 n'a pas été exécuté !
                Vous sortez à 1.09500 → -50 pips au lieu de -30

Le gap a "sauté" votre Stop Loss.
La Fermeture Horaire (vendredi soir) aurait évité ce scénario.
```

---

## 🏢 Prop Firms et horaires de trading

### Règles courantes des Prop Firms

| Prop Firm | Overnight autorisé ? | Week-end autorisé ? | Recommandation |
|:---:|:---:|:---:|:---:|
| FTMO | ✅ Oui | ❌ Non (challenge) | Fermer vendredi |
| MyForexFunds | ⚠️ Dépend du plan | ❌ Non | Fermer chaque soir |
| The5ers | ✅ Oui | ✅ Oui | Optionnel |
| Funding Pips | ⚠️ Dépend | ❌ Non | Fermer vendredi |

### Configuration recommandée pour Prop Firms

```
Heure_Fermeture          = 22    (22h00 broker = fin de session US)
Minute_Fermeture         = 0
Symbole_Courant_Seulement = false   (fermer TOUT)
```

---

## ⚙️ Configuration et paramètres

| Paramètre | Type | Défaut | Description |
|:---:|:---:|:---:|:---|
| `Heure_Fermeture` | int | 17 | Heure de fermeture (heure broker, 0-23) |
| `Minute_Fermeture` | int | 0 | Minute de fermeture (0-59) |
| `Symbole_Courant_Seulement` | bool | false | true = ce symbole, false = tout |

### Configurations recommandées

| Profil | Heure | Minute | Scope | Explication |
|:-:|:-:|:-:|:-:|:---|
| Day trader EU | 17 | 00 | Tout | Fin session européenne |
| Day trader US | 22 | 00 | Tout | Fin session US |
| Scalper matin | 12 | 30 | Symbole | Fin session matin |
| Prop Firm | 22 | 45 | Tout | 15 min avant minuit broker |
| Vendredi soir | 20 | 00 | Tout | Avant le week-end |

### Exemple de combinaison multi-graphiques

```
Graphique EURUSD  → FermetureHoraireBot (17:00, symbole courant)
Graphique GBPUSD  → FermetureHoraireBot (17:30, symbole courant)
Graphique USDJPY  → FermetureHoraireBot (15:00, symbole courant)

Chaque symbole a son propre horaire de fermeture !
```

---

## ❌ Gestion des erreurs

### Erreurs de paramètres

| Erreur | Cause | Solution |
|:---:|:---|:---|
| Heure < 0 ou > 23 | Heure invalide | Utilisez 0-23 |
| Minute < 0 ou > 59 | Minute invalide | Utilisez 0-59 |

### Erreurs de fermeture

| Situation | Cause | Action |
|:---:|:---|:---|
| Position non fermée | Marché fermé | Retry au prochain tick |
| Slippage | Volatilité | Déviation acceptée (10 points) |
| Aucune position | Pas de trades ouverts | Info dans les logs |

---

## 🧪 Tests et backtest

### Test en temps réel (compte démo)

1. Ouvrez un **compte démo**
2. Configurez la fermeture dans **2-3 minutes** (ex : si il est 14:15, mettez 14:17)
3. Ouvrez 2-3 positions manuellement
4. Attendez l'heure de fermeture
5. Vérifiez que **TOUTES** les positions sont fermées
6. Vérifiez que l'EA **ne re-ferme pas** (flag = true)
7. Le lendemain, vérifiez que le flag est réinitialisé

### Points à vérifier

- [ ] Les positions sont fermées à l'heure exacte
- [ ] Le flag empêche les fermetures multiples
- [ ] Le flag se réinitialise au changement de jour
- [ ] Option "symbole courant" fonctionne correctement
- [ ] Les logs affichent les détails de chaque fermeture
- [ ] L'heure dans les logs correspond à l'heure broker

---

## ❓ FAQ

### L'EA utilise-t-il mon heure locale ou celle du broker ?

L'heure du **broker** (`TimeCurrent()`). C'est important car il peut y avoir un décalage de 1 à 7 heures selon votre position géographique et le fuseau du broker.

### Que se passe-t-il si le marché est fermé à l'heure configurée ?

L'EA ne reçoit pas de tick quand le marché est fermé, donc il ne peut pas fermer les positions. Si vous configurez 17:00 et que le marché ferme à 16:30, les positions resteront ouvertes. Configurez toujours l'heure **pendant les heures d'ouverture** du marché.

### Puis-je avoir deux horaires de fermeture différents ?

Pas avec un seul EA. Mais vous pouvez placer **deux instances** de l'EA sur deux graphiques différents avec des horaires différents.

### L'EA ferme-t-il les ordres en attente (Pending Orders) ?

**Non.** L'EA ferme uniquement les **positions ouvertes** (trades actifs). Les ordres en attente (Limit, Stop) ne sont pas affectés. Pour les supprimer, il faudrait ajouter une logique avec `OrdersTotal()` et `OrderDelete()`.

### Cet EA ouvre-t-il des positions ?

**Non.** C'est un EA de **gestion pure**. Il ferme des positions existantes à une heure donnée.

---

## 🔗 Liens utiles

### Nos autres tutoriels
- 🛡️ [Tuto MT5 — Stop Loss Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Stop-Loss-Automatique)
- 🎯 [Tuto MT5 — Take Profit Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique)
- 📊 [Tuto MT5 — TP Partiel Automatique](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique)
- 📈 [Tuto MT5 — Trailing Stop Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Trailing-Stop-Automatique)
- 🔒 [Tuto MT5 — Break Even Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Break-Even-Automatique)
- 🚨 [Tuto MT5 — Max Drawdown Daily](https://github.com/VOTRE_USER/Tuto-MT5-Max-Drawdown-Daily)

### Documentation officielle
- 📖 [Documentation MQL5 complète](https://www.mql5.com/fr/docs)
- 📖 [TimeCurrent()](https://www.mql5.com/fr/docs/dateandtime/timecurrent)
- 📖 [MqlDateTime Structure](https://www.mql5.com/fr/docs/dateandtime/mqldatetime)
- 📖 [Classe CTrade - PositionClose](https://www.mql5.com/fr/docs/standardlibrary/tradeclasses/ctrade/ctradepositionclose)

### Téléchargements
- ⬇️ [MetaTrader 5](https://www.metatrader5.com/fr/download)

---

### 🎬 Vidéo tutoriel

[![Voir la vidéo sur YouTube](https://img.youtube.com/vi/HrCb3Lcgyd0/maxresdefault.jpg)](https://www.youtube.com/watch?v=HrCb3Lcgyd0)

---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE). Vous êtes libre de l'utiliser, le modifier et le distribuer.

---

<p align="center">
  Fait par <a href="https://autoea.online">EA Creator</a>
</p>
