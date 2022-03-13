from pyswip import Query, Prolog, Variable
from pyswip.easy import Atom, Functor
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("ia_deep", help="search deep of min-max algorithm", type=int)
args = parser.parse_args()

prolog = Prolog()
prolog.consult('_main.pl')

top = [ ' ', '\\', '_', '_', '_', '/', ' ']
top2 = [ ' ', '/', ' ', ' ', ' ', '\\', ' ']
top3 = [ '/', ' ', ' ', ' ', ' ', ' ', '\\']
top4 = [ '\\', ' ', ' ', ' ', ' ', ' ', '/']
top5 = [ ' ', '\\', '_', '_', '_', '/', ' ']

def next_turn(): 
  print("Simulate")
  print()
  list(prolog.query('turn_finish()'))
  list(prolog.query('simulate_steep('+ str(args.ia_deep) +',Result)'))
  list(prolog.query('turn_finish()'))

def insect_tuple(tuplee: Functor):
  atom = tuplee.args[0]
  func = tuplee.args[1]
  return atom.value, func.args[1]

def print_table(table, xi, yi, x_deep, y_deep):
  if len(table) == 0: return 0

  x= []
  y = []
  _dict = {}
  for item in table:
    x.append( int(item.args[1].args[0]) )
    y.append( int(item.args[1].args[1]) )
    _dict[(x[-1], y[-1])] = (str(item.args[0].args[0]) , str(item.args[0].args[1].args[0]))

  # print(_dict)
  def index(e, j, s = 0):
    result = [' ', ' ', ':', ' ', ' ']
    i = str( xi -1 + 2*j + s)
    try:
      result[1] = i[1]
      result[0] = i[0]
    except:
      result[1] = i

    i = str(yi -1 + e-j)
    try:
      result[3] = i[0]
      result[4] = i[1]
    except:
      result[3] = i
    
    return result

  def insect(_dict, e, j, s= 0):
    try:
      i = int(xi -1 +  (2*j + s)) 
      r = int(yi -1 + ((e - s) - j))
      insect, player = _dict[(i,r)]
      return [' ', insect[0].upper(), ':', player[0].upper(), ' ']
    except:
      return [' ', ' ', ' ', ' ', ' ']


  table = []
  for i in range(y_deep * 4 + 3):
    table.append([])

  for i in range(round(x_deep/2 + 0.5)):
    table[0]  += [ ' ', '\\', '_', '_', '_', '/', ' ', ' ', ' ', ' ']
    table[-2] += [ ' ', '/', ' ', ' ', ' ', '\\', ' ', ' ', ' ', ' ']
    table[-1] += [ '/', ' ', ' ', ' ', ' ', ' ', '\\', '_', '_', '_']

  table[0]  += [ ' ', '\\']
  table[-2] += [ ' ', '/']
  table[-1] += [ '/', ' ']
  for e, i in enumerate(range(1, y_deep*4, 4)):
    table[i]     += [ ' ' ] 
    table[i + 1] += [ '/' ]
    table[i + 2] += [ '\\']
    table[i + 3] += [ ' ' ] 
    for j in range(round(x_deep/2 + 0.5)):
      if i + 3 >= len(table): continue
      table[i]     += [ '/', ' ', ' ', ' ', '\\'] +  insect(_dict, e, j, 1)
      table[i + 1] += index(e, j) + [ '\\', '_', '_', '_' ,  '/']
      table[i + 2] += insect(_dict, e, j) + [ '/' , ' ', ' ', ' ',  '\\']
      table[i + 3] += [ '\\', '_', '_', '_', '/'] +  index(e, j, 1)
    table[i]     += [  '/' ]
    table[i + 1] += [  ' ' ]
    table[i + 2] += [  ' ']
    table[i + 3] += [  '\\']


  for row in table: 
    for i in row:
      print(i, end='')
    print()
  
  return deep

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
  place = re.search(r'(-\d+\s*|\d+\s*):(\s*-\d+|\s*\d+)', action)
  if select is None or place is None: return set_action(1)

  index = int(select.group()[1:-1])
  pos = place.group().split(':')
  result =list(prolog.query('set_insect((' + str(insect[index][0]) + 
               ',' + str(insect[index][1]) + 
               '),' + str(int(pos[0])) +
               ',' + str(int(pos[1])) + ', Result)' ))

    
  _result = result[0]['Result']
  if not "finish" in str(_result): 
    print("Error:", _result)
    set_action(1)

  print('Set result:', result[0]['Result'])
  next_turn()

def mov_action(option): 
  if option != 2: return 
  print('Write your new mov. (Example: mov insect [1] to 2:3)')
  option_list = list(prolog.query('insect_available_to_mov(List)'))[0]['List']

  insect = []
  for i, t in enumerate(option_list):
    t = insect_tuple(t)
    insect.append(t)
    print(i, '- ', t[0], '-', t[1])

  action = input()
  select = re.search(r'\[\s*\d+\s*\]', action)
  place = re.search(r'(-\d+\s*|\d+\s*):(\s*-\d+|\s*\d+)', action)
  if select is None or place is None: return  mov_action(2)

  index = int(select.group()[1:-1])
  pos = place.group().split(':')
  result =list(prolog.query('mov_insect((' + str(insect[index][0]) + 
               ',' + str(insect[index][1]) + 
               '),' + str(int(pos[0])) +
               ',' + str(int(pos[1])) + ', Result)' ))
  
  _result = result[0]['Result']
  if not "finish" in str(_result): 
    print("Error:", _result)
    mov_action(2)

  print('Set result:', result[0]['Result'])
  next_turn()

def pill_bug_effect(option):
    if option != 3: return 
    print('Write your new mov. (Example: mov insect [1:1] to 2:3)')

    action = input()
    select = re.search(r'\[\s*(-\d+\s*|\d+\s*):(\s*-\d+|\s*\d+)\s*\]', action)
    place = re.search(r'(-\d+\s*|\d+\s*):(\s*-\d+|\s*\d+)', action)
    if select is None or place is None: return  mov_action(2)

    index = select.group()[1:-1]
    a_pos = index.split(':')
    pos = place.group().split(':')
    result =list(prolog.query('pill_bug_effect_insect((' + str(int(a_pos[0])) + 
                 ',' + str(int(a_pos[1])) + 
                 '),(' + str(int(pos[0])) +
                 ',' + str(int(pos[1])) + '), Result)' ))

    _result = result[0]['Result']
    if not "finish" in str(_result): 
      print("Error:", _result)
      pill_bug_effect(3)

    print('Set result:', result[0]['Result'])
    next_turn()

def simulate_play():
  try: 
    while True:
      print("Simulated ....")
      sim = list(prolog.query('simulate_steep('+ str(args.ia_deep) +',Result)'))
      print(sim[0]['Result'])
      if not str(sim[0]['Result']) == 'Not finish':  break
      list(prolog.query('turn_finish()'))
      table = list(prolog.query('get_table(Table)'))
      print_table(table[0]['Table'], -2, -2, 10, 10)
  except KeyboardInterrupt: 
    pass
  
  xi, yi, x_deep, y_deep = -2, -2, 10, 10
  while True: 
    table = list(prolog.query('get_table(Table)'))
    print_table(table[0]['Table'], xi, yi, x_deep, y_deep)

    print("Write any think of press Ctrl+C")
    input()
    xi, yi, x_deep, y_deep = xi - 0.5, yi - 0.5, x_deep + 1, y_deep + 1 

xi, yi, x_deep, y_deep = 0, 0, 3, 3
while True:
  table = list(prolog.query('get_table(Table)'))
  deep = print_table(table[0]['Table'], int(xi), int(yi), x_deep, y_deep)

  set_cond = list(prolog.query('set_condition(X)'))
  mov_cond = list(prolog.query('mov_condition(X)'))
  pill_cond = list(prolog.query('pill_bug_effect_condition(X)'))
  
  if set_cond or mov_cond: print('Select option for your next steep in play:')
  else: 
    next_turn()
    continue 
  print('0- Zoom Table')
  if len(set_cond) > 0: print(set_cond[0]['X'])
  if len(mov_cond) > 0: print(mov_cond[0]['X'])
  if len(pill_cond) > 0: print(pill_cond[0]['X'])
  print('4- Simulate PLay')


  try:
    select_option = int(input())
  except TypeError: continue
  except ValueError: continue

  if select_option == 0: 
    xi, yi, x_deep, y_deep = xi - 0.5, yi - 0.5, x_deep + 1, y_deep + 1 
  
  if select_option == 4:
    simulate_play()
    break

  set_action(select_option)
  mov_action(select_option)
  pill_bug_effect(select_option)
  