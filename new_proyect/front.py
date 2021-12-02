from pyswip import Query, Prolog, Variable
from pyswip.easy import Atom, Functor
import re

prolog = Prolog()
prolog.consult('_main.pl')

top = [ ' ', '\\', '_', '_', '_', '/', ' ']
top2 = [ ' ', '/', ' ', ' ', ' ', '\\', ' ']
top3 = [ '/', ' ', ' ', ' ', ' ', ' ', '\\']
top4 = [ '\\', ' ', ' ', ' ', ' ', ' ', '/']
top5 = [ ' ', '\\', '_', '_', '_', '/', ' ']

def insect_tuple(tuplee: Functor):
  atom = tuplee.args[0]
  func = tuplee.args[1]
  return atom.value, func.args[1]

def set_action(option):
  if option != 1: return

  print('Write your new mov. (Example: set insect [1] in place 2:3)')
  option_list = list(prolog.query('insect_available_to_set(List)'))[0]['List']

  insect = []
  for i, t in enumerate(option_list):
    t = insect_tuple(t)
    insect.append(t)
    print(i, '- ', t[0], '-', t[1])

  action = input()
  select = re.search(r'\[\s*\d+\s*\]', action)
  place = re.search(r'\d+\s*:\s*\d+', action)
  if select is None or place is None: return set_action(1)
  
  index = int(select.group()[1:-1])
  pos = place.group().split(':')
  prolog.query('set_insect((' + str(insect[index][0]) + 
               ',' + str(insect[index][1]) + 
               '),' + str(int(pos[0])) +
               ',' + str(int(pos[1])) + ', Result)' )

while True:
  print('Select option for your next steep in play:')
  set_cond = list(prolog.query('set_condition(X)'))
  mov_cond = list(prolog.query('mov_condition(X)'))

  if len(set_cond) > 0: print(set_cond[0]['X'])
  if len(mov_cond) > 0: print(mov_cond[0]['X'])

  select_option = int(input())

  set_action(select_option)
  
    
