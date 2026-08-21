import json
import os
import math
from datetime import datetime

FIELD_OPERATORS = {
    "CVE": ["==", "!=", ":=", "!:="],           # Chaine
    "CWE": ["==", "!=", ":=", "!:="],           # Liste
    "DATE": ["==", "!=", ">", "<", ">=", "<="], # Date 
    "SCORE": ["==", "!=", ">", "<", ">=", "<="], # Nombre 
    "METRIC": ["==", "!=", ":=", "!:="],        # Chaine
    "TITLE": ["==", "!=", ":=", "!:="],         # Chaine
    "DESC": ["==", "!=", ":=", "!:="],          # Chaine
    "PRODUIT": ["==", "!=", ":=", "!:="]         # CHAINE
}


def json_to_dict(filename : str) -> dict:
    with open(filename, 'r') as f:
        data = f.read()
        json_data = json.loads(data)
        return json_data


def load_json_by_range_year(logicTab : list) -> dict:
    yearA, yearB = 2015, 2026
    
    json_data = dict()

    for year in range(yearA, yearB+1):
        json_data[str(year)] = dict()
        for json_cve in os.listdir(f"db/{year}/"):
            temp_data = json_to_dict(f"db/{year}/{json_cve}")
            if logicTab is None or is_valid_cve_by_logic_tab(temp_data, logicTab):
                json_data[str(year)][json_cve.split('.')[0]] = temp_data
    
    return json_data

def expression_to_tab(logicExpression : str) -> list:
    nb_operators = logicExpression.count("||") + logicExpression.count("&&")
    nb_groups = nb_operators + 1
    total_elements = nb_groups + nb_operators

    tab = [[] for i in range(total_elements)]
    
    i = 0
    
    for op in logicExpression.split(' '):
        if op == "&&" or op == "||":
            i += 1
            tab[i] = op
            i += 1
        else:
            tab[i].append(op)
    return tab


def is_valid_cve_by_logic_tab(cve: dict, logicTab: list):
    result = None
    cond = None
    next_op = None
    
    for expr in logicTab:
        if expr not in ["&&", "||"]:
            mot_cle, op, valueRaw = expr[0], expr[1], expr[2].strip('"\'')
            
            if op in [":=", "!:="]:
                value = [v.strip() for v in valueRaw.strip('[]').split(',')]
            else:
                value = valueRaw
            
            if mot_cle in FIELD_OPERATORS and op not in FIELD_OPERATORS[mot_cle]:
                raise ValueError(f"Opérateur '{op}' non autorisé pour le champ '{mot_cle}'. "
                               f"Opérateurs autorisés : {', '.join(FIELD_OPERATORS[mot_cle])}")
            
            mot_cle_val = cve.get(mot_cle)
            if mot_cle_val is None or mot_cle_val == '':
                cond = False
                result = cond if result is None else (result or cond if next_op == "||" else result and cond)
                next_op = None
                continue

            if op == "==":
                cond = mot_cle_val == value if not isinstance(mot_cle_val, list) else value in mot_cle_val
            elif op == ":=":
                cond = any(v in (mot_cle_val if isinstance(mot_cle_val, list) else str(mot_cle_val)) for v in value)
            elif op == "!=":
                cond = mot_cle_val != value if not isinstance(mot_cle_val, list) else value not in mot_cle_val
            elif op == "!:=":
                cond = not any(v in (mot_cle_val if isinstance(mot_cle_val, list) else str(mot_cle_val)) for v in value)
            elif op in [">", "<", ">=", "<="]:
                if mot_cle == "DATE":
                    a = datetime.strptime(mot_cle_val, "%Y-%m-%d %H:%M:%S")
                    b = datetime.strptime(value, "%Y-%m-%d")
                else:
                    a, b = float(mot_cle_val), float(value)
                
                cond = (a > b if op == ">" else a < b if op == "<" else 
                       a >= b if op == ">=" else a <= b)
            
            result = cond if result is None else (result or cond if next_op == "||" else result and cond)
            next_op = None
        else:
            next_op = expr

    return result if result is not None else False



def get_score_range(score):
    if score == 0:
        return "None"
    elif score < 4.0:
        return "Low"
    elif score < 7.0:
        return "Medium"
    elif score < 9.0:
        return "High"
    else:
        return "Critical"


        
