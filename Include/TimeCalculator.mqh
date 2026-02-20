//+------------------------------------------------------------------+
//|                                           TimeCalculator.mqh     |
//|              Tuto MT5 - Fermeture Horaire Automatique            |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : EstHeureDeFermer                                      |
//| Vérifie si l'heure actuelle du broker a atteint ou dépassé       |
//| l'heure de fermeture configurée.                                 |
//|                                                                  |
//| COMMENT FONCTIONNE LE TEMPS EN MQL5 ?                            |
//|                                                                  |
//| MT5 fournit plusieurs sources de temps :                         |
//|                                                                  |
//| TimeCurrent()     → Heure du dernier tick reçu (heure broker)    |
//| TimeLocal()       → Heure de votre PC (heure locale)             |
//| TimeTradeServer() → Heure du serveur (peut être différente)      |
//|                                                                  |
//| On utilise TimeCurrent() car :                                   |
//| 1. C'est l'heure du BROKER (référence pour les charts)           |
//| 2. Elle est cohérente avec les bougies et les horaires           |
//| 3. Elle ne dépend pas des paramètres de votre PC                 |
//|                                                                  |
//| ⚠️ ATTENTION : l'heure du broker ≠ votre heure locale !          |
//|   Si votre broker est GMT+2 et vous êtes GMT+1,                  |
//|   17h broker = 16h chez vous.                                    |
//|                                                                  |
//| FONCTIONS D'EXTRACTION DU TEMPS :                                |
//|                                                                  |
//| MqlDateTime est une structure qui décompose un datetime en :      |
//|   .year, .mon, .day, .hour, .min, .sec, .day_of_week            |
//|                                                                  |
//| TimeToStruct(datetime, MqlDateTime&) convertit un timestamp       |
//| en structure lisible.                                             |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   heure  (int) - heure de fermeture (0-23)                       |
//|   minute (int) - minute de fermeture (0-59)                      |
//| Retour : bool - true si l'heure de fermeture est atteinte        |
//+------------------------------------------------------------------+
bool EstHeureDeFermer(int heure, int minute)
{
    // Récupérer l'heure actuelle du broker
    datetime maintenant = TimeCurrent();

    // Convertir en structure MqlDateTime pour accéder à .hour et .min
    MqlDateTime tempsDecompose;
    TimeToStruct(maintenant, tempsDecompose);

    int heureActuelle  = tempsDecompose.hour;
    int minuteActuelle = tempsDecompose.min;

    // Comparer : l'heure actuelle a-t-elle ATTEINT ou DÉPASSÉ le seuil ?
    //
    // On compare en "minutes totales" pour simplifier :
    //   17:30 = 17 × 60 + 30 = 1050 minutes
    //   17:45 = 17 × 60 + 45 = 1065 minutes
    //   1065 >= 1050 → OUI, l'heure est dépassée

    int minutesTotalesActuelles = heureActuelle * 60 + minuteActuelle;
    int minutesTotalesFermeture = heure * 60 + minute;

    return (minutesTotalesActuelles >= minutesTotalesFermeture);
}

//+------------------------------------------------------------------+
//| Fonction : FormaterHeure                                         |
//| Formate une heure et minute en string "HH:MM".                   |
//+------------------------------------------------------------------+
string FormaterHeure(int heure, int minute)
{
    string h = (heure < 10) ? "0" + IntegerToString(heure) : IntegerToString(heure);
    string m = (minute < 10) ? "0" + IntegerToString(minute) : IntegerToString(minute);
    return h + ":" + m;
}

//+------------------------------------------------------------------+
//| Fonction : FormaterHeureActuelle                                 |
//| Retourne l'heure actuelle du broker en format "HH:MM:SS".       |
//+------------------------------------------------------------------+
string FormaterHeureActuelle()
{
    datetime maintenant = TimeCurrent();
    MqlDateTime tempsDecompose;
    TimeToStruct(maintenant, tempsDecompose);

    string h = (tempsDecompose.hour < 10) ? "0" + IntegerToString(tempsDecompose.hour)
               : IntegerToString(tempsDecompose.hour);
    string m = (tempsDecompose.min < 10) ? "0" + IntegerToString(tempsDecompose.min)
               : IntegerToString(tempsDecompose.min);
    string s = (tempsDecompose.sec < 10) ? "0" + IntegerToString(tempsDecompose.sec)
               : IntegerToString(tempsDecompose.sec);

    return h + ":" + m + ":" + s;
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirJourSemaine                                    |
//| Retourne le jour de la semaine (0=Dimanche, 5=Vendredi).         |
//| Utile pour ajouter un filtre "pas de fermeture le week-end".     |
//+------------------------------------------------------------------+
int ObtenirJourSemaine()
{
    datetime maintenant = TimeCurrent();
    MqlDateTime tempsDecompose;
    TimeToStruct(maintenant, tempsDecompose);
    return tempsDecompose.day_of_week;
}

//+------------------------------------------------------------------+
//| Fonction : EstJourDeSemaine                                      |
//| Vérifie que c'est un jour ouvrable (Lundi à Vendredi).           |
//+------------------------------------------------------------------+
bool EstJourDeSemaine()
{
    int jour = ObtenirJourSemaine();
    // 0 = Dimanche, 6 = Samedi
    return (jour >= 1 && jour <= 5);
}
