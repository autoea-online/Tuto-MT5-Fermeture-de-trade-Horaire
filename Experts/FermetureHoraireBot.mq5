//+------------------------------------------------------------------+
//|                                       FermetureHoraireBot.mq5    |
//|              Tuto MT5 - Fermeture Horaire Automatique            |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DESCRIPTION GÉNÉRALE                                             |
//|                                                                  |
//| Cet Expert Advisor (EA) ferme automatiquement TOUTES les         |
//| positions ouvertes à une heure précise, chaque jour.             |
//|                                                                  |
//| Pourquoi fermer à heure fixe ?                                   |
//|                                                                  |
//| ✅ Day trading pur : pas de positions overnight                  |
//| ✅ Éviter les swaps (frais de nuit)                               |
//| ✅ Prop Firms : certaines interdisent le overnight               |
//| ✅ Réduire le risque de gap d'ouverture (lundi matin)            |
//| ✅ Discipline : fin de journée = fin du trading                  |
//|                                                                  |
//| Exemple :                                                        |
//| - Vous tradez entre 8h et 17h                                   |
//| - À 16h55, vous configurez l'EA pour fermer tout à 17h00         |
//| - Même si vous avez oublié une position ouverte, l'EA la ferme   |
//|                                                                  |
//| C'est un "nettoyeur automatique" de fin de journée.              |
//|                                                                  |
//| STRUCTURE DES FICHIERS :                                         |
//|                                                                  |
//| FermetureHoraireBot.mq5          ← Fichier principal (celui-ci)  |
//|  ├── Include/TradeSelector.mqh    ← Sélection des positions      |
//|  ├── Include/TimeCalculator.mqh   ← Logique de temps             |
//|  └── Include/TradeManager.mqh     ← Fermeture des positions      |
//+------------------------------------------------------------------+

// ===================================================================
// PROPRIÉTÉS DE L'EA
// ===================================================================

#property copyright   "EA Creator - autoea.online"
#property link        "https://autoea.online"
#property version     "1.00"
#property description "EA qui ferme toutes les positions"
#property description "a une heure precise (fin de journée)."
#property description ""
#property description "Generateur EA sans code : https://autoea.online"

// ===================================================================
// INCLUSIONS
// ===================================================================

#include "Include\TradeSelector.mqh"    // Sélection des positions
#include "Include\TimeCalculator.mqh"   // Calcul du temps
#include "Include\TradeManager.mqh"     // Fermeture des positions

// ===================================================================
// PARAMÈTRES D'ENTRÉE (INPUT)
// ===================================================================

// Heure de fermeture (heure du BROKER, pas votre heure locale !)
// Format 24h : 17 = 17h00, 22 = 22h00
input int Heure_Fermeture = 17;     // Heure de fermeture (0-23)

// Minute de fermeture
// Combiné avec l'heure : 17h30, 22h45, etc.
input int Minute_Fermeture = 0;     // Minute de fermeture (0-59)

// Fermer uniquement les positions du symbole courant
// true  = ferme SEULEMENT les positions de ce graphique
// false = ferme TOUTES les positions de TOUS les symboles
input bool Symbole_Courant_Seulement = false;   // Symbole courant uniquement ?

// ===================================================================
// VARIABLES GLOBALES
// ===================================================================

// Flag pour éviter de fermer plusieurs fois à la même heure.
// Sans ce flag, l'EA fermerait à chaque tick pendant toute la minute
// de fermeture (des centaines de tentatives !).
bool DejaFermeAujourdhui = false;

// Date du dernier reset du flag (pour le réinitialiser le lendemain)
datetime DerniereDate;

// ===================================================================
// FONCTION OnInit()
// ===================================================================

int OnInit()
{
    // Validation de l'heure
    if(Heure_Fermeture < 0 || Heure_Fermeture > 23)
    {
        Print("❌ ERREUR : L'heure doit être entre 0 et 23 !");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Validation des minutes
    if(Minute_Fermeture < 0 || Minute_Fermeture > 59)
    {
        Print("❌ ERREUR : Les minutes doivent être entre 0 et 59 !");
        return INIT_PARAMETERS_INCORRECT;
    }

    DerniereDate = iTime(_Symbol, PERIOD_D1, 0);
    DejaFermeAujourdhui = false;

    Print("══════════════════════════════════════════");
    Print("⏰ Fermeture Horaire Bot démarré !");
    Print("   Symbole         : ", _Symbol);
    Print("   Heure fermeture : ", FormaterHeure(Heure_Fermeture, Minute_Fermeture));
    Print("   Scope           : ", Symbole_Courant_Seulement ?
          "Ce symbole uniquement" : "TOUTES les positions");
    Print("   Heure broker    : ", FormaterHeureActuelle());
    Print("══════════════════════════════════════════");

    return INIT_SUCCEEDED;
}

// ===================================================================
// FONCTION OnDeinit()
// ===================================================================

void OnDeinit(const int reason)
{
    Print("🛑 Fermeture Horaire Bot arrêté. Raison : ", reason);
}

// ===================================================================
// FONCTION OnTick() — CŒUR DE L'EA
// ===================================================================

void OnTick()
{
    // ─────────────────────────────────────────────────
    // ÉTAPE 1 : Réinitialiser le flag si nouveau jour
    // ─────────────────────────────────────────────────

    datetime dateActuelle = iTime(_Symbol, PERIOD_D1, 0);

    if(dateActuelle != DerniereDate)
    {
        DerniereDate = dateActuelle;
        DejaFermeAujourdhui = false;
        Print("📅 Nouveau jour — Fermeture horaire réarmée pour ",
              FormaterHeure(Heure_Fermeture, Minute_Fermeture));
    }

    // ─────────────────────────────────────────────────
    // ÉTAPE 2 : Vérifier si déjà fermé aujourd'hui
    // ─────────────────────────────────────────────────

    if(DejaFermeAujourdhui)
        return;

    // ─────────────────────────────────────────────────
    // ÉTAPE 3 : Vérifier si c'est l'heure de fermer
    // ─────────────────────────────────────────────────

    if(!EstHeureDeFermer(Heure_Fermeture, Minute_Fermeture))
        return;

    // ─────────────────────────────────────────────────
    // ⏰ C'EST L'HEURE ! FERMER TOUT !
    // ─────────────────────────────────────────────────

    Print("══════════════════════════════════════════");
    Print("⏰ HEURE DE FERMETURE ATTEINTE : ", FormaterHeureActuelle());
    Print("══════════════════════════════════════════");

    int nbPositions = 0;
    if(Symbole_Courant_Seulement)
        nbPositions = CompterPositionsSymbole();
    else
        nbPositions = CompterPositionsOuvertes();

    if(nbPositions == 0)
    {
        Print("ℹ️ Aucune position ouverte à fermer.");
    }
    else
    {
        Print("📊 ", nbPositions, " position(s) à fermer...");

        int nbFermees = 0;
        if(Symbole_Courant_Seulement)
            nbFermees = FermerPositionsSymbole();
        else
            nbFermees = FermerToutesPositions();

        Print("✅ ", nbFermees, " / ", nbPositions, " position(s) fermée(s).");
    }

    // Marquer comme exécuté pour aujourd'hui
    DejaFermeAujourdhui = true;
    Print("🛑 Fermeture horaire terminée. Prochain déclenchement : demain ",
          FormaterHeure(Heure_Fermeture, Minute_Fermeture));
}
