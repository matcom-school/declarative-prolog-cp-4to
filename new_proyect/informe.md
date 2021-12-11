# Informe Primer Proyecto de Programación Declarativa Hive

## Integrantes:

- Daniel Orlando Ortiz Pacheco
- Aldo Javier Veldesia

# Objetivo: La Implementación en Prolog del Juego Hive y de una IA del mismo

## Requisitos Funcionales:

Para ejecutar el proyecto se necesita de SWI-Prolog, compilador del prolog, en su versión 8.3.29 y pyswip librería de Python que se utilizó para conectar a Python con SWI-Prolog. Una vez instaladas las dependencias, con una consola en el root del proyecto ejecute el comando `python front.py ia_deep`, el parámetro `ia_deep` debe sustituirse por un entero que especificará la profundidad que tendrán los árboles de búsqueda. Luego de ejecutar el comando siga las instrucciones que el programa le va a ir mostrando.

## Desarrollo:

Para la resolución de esta tarea se utilizó Prolog para describir y controlar todas las reglas del juego y Python para representar en consola el Hive y todos los insectos sobre él mismo. El desarrollo se dividió en 4 distintos problemas:

- Colocar un insecto en el Hive
- Mover un insecto en el Hive
- Usar el poder el Pillbug
- Una IA para decidir el siguiente paso del juego

Como tarea inicial, se investigó como representar computacionalmente el Hive. El Hive es un tablero hexagonal y tan grande como la cantidad de insectos en juego. Finalmente se opto por una representación bidimensional del mismo, donde se define que:

        ⍫ i,j ⍷ N, i,j posiciones del Hive entonces las posiciones (i, j+1), (i+1, j),(i-1, j+1), (i-1, j),(i, j-1), (i+1, j-1) son sus posiciones adyacentes a la posición (i,j).

Siguiendo esa idea el Hive fue implementado usando la meta programación de Prolog, gracias a los métodos `assert`, `retract` y definiendo el predicado dinámico `insect_play/3`.

El control de las reglas del juego a la hora de colocar un insecto en el Hive se dividió el desarrollo en dos predicados de Prolog, uno encargado de actualizar el Hive si la posición seleccionada es correcta y el insecto esta disponible para el jugador (`set_insect (Insect, Index) by Player of_index (X, Y) with Result`). Y otro que controla todas las reglas de este proceso, dicho predicado es veraz solo cuando hay algún error en la acción (`set_fail_condition(Insect, Index, Player, X, Y, Result`. Sea Insect,Index, Player, X, Y una entrada de estos predicados se pueden obtener distintos Result:

- “Finish: win white”: No se rompió ninguna regla y el jugador blanco acaba de ganar
- “Finish: win black”: No se rompió ninguna regla y el jugador negro acaba de ganar
- “Not Finish”: No se rompió ninguna regla y el juego sigue
- “La posición inicial debe ser la 0:0”: Cuando no hay ninguna pieza en juego y se intenta colocar un insecto en una posición distinta de la 0:0
- “Posición Ocupada”: Cuando se intenta colocar un insecto sobre otro
- “Insecto no Disponible”: Cuando se intenta colocar un insecto que ya a sido colocado
- “Posición Desconectada”: Cuando la posición seleccionada no es adyacente a alguna de las piezas antes colocada
- “Falta por colocar la reina”: Cuando se intenta colocar un insecto por 4 ocasión, pero aun no se ha colocado la reina
- “Toca un insecto del contrario”: A partir de el primer insecto colocado no se puede colocar otro adyacente a un insecto contrario

Análogamente al proceso de colocación, en el movimiento de los insectos se dividió el desarrollo en dos predicados (`mov((Insect, Player, Index), (X, Y), Result)` y `mov_fail_condition((Insect, Index, Player), (ActualX, ActualY), (X, Y), Result)`). Este caso es más complejos que en el anterior pues cada insecto tiene características especificas a la hora de moverse y como tal el predicado `mov_fail_condition` se divide para recoger todas estas reglas:

- “Finish: win white”: No se rompió ninguna regla y el jugador blanco acaba de ganar
- “Finish: win black”: No se rompió ninguna regla y el jugador negro acaba de ganar
- “Not Finish”: No se rompió ninguna regla y el juego sigue
- “La reina no esta colocada”: Por regla general, no se puede realizar movimientos antes de colocar la reina respectiva del jugador
- “La Pieza esta Bloqueada”: Cuando un escarabajo esta encima de la pieza que se pide mover, esta particularidad se maneja con una lista enlaza con el predicado dinámico `dont_mov((BInsect, BPlayer, BIndex), (Insect, Player, Index))`, que se actualiza con los movimientos de los escarabajos.
- “Mov Desconecta el Hive”: Cuando el movimiento rompe el Hive, para controlar esta regla se simulan el movimiento y se analiza si el resultado es una componente conexa
- “Posición Ocupada”: Cuando la posicione destino esta ocupada, esta regla se analiza para para todos los insectos menos para el escarabajo
- “Posición No Adyacente”: Regla que se aplica solo a la abeja reina, el escarabajo y el bicho bola, que son los insectos que se solo se pueden mover a posiciones adyacentes
- “El Camino no es Lineal” : Cuando la posición de destino y la origen no definen una linea recta en el Hive, regla que se controla únicamente para los movimientos de los saltamontes. Para controlar esta regla nos apoyamos en las direcciones definidas anteriormente y garantizando que la posición destino se puede obtener a partir de la suma sucesiva de una de esas direcciones más el origen
- “El Camino Tiene Huecos Vacíos”: En unión con la regla anterior se controla que todos los pasos del camino recto del saltamontes este ocupado por algún insecto menos la posición destino
- “La posición no se encontró disponible tres pasos mas adelante”: En el caso de la araña, cuando no se encuentra camino entre el origen y el destino señalado, para encontrar dicho camino realiza una búsqueda en bfs por todas las posiciones vacías del Hive que tiene algún insecto adyacente
- “No se encontró camino posible”: En el caso de la hormiga, que puede moverse por todo el tablero siempre por posiciones adyacentes de los insectos del tablero, esta regla se apoya en la búsqueda del caso anterior
- “No se encontró camino sobre el Hive”: De manera similar a los dos casos anteriores la mariquita se mueve dos pasos por encima del Hive, para terminar en una posición disponible. La regla se controla con una búsqueda en bfs por las posiciones ocupadas del Hive
- “El mosquito solo tiene al lado a otro mosquito”: El mosquito no se puede mover cuando esta solo esta al lado de otro mosquito.
- “Ninguno de los adyacentes puede realizar ese movimiento”: Cuando ninguno de los insectos al rededor del mosquito no pueden realizar el movimiento solicitado para el mosquito. Lo cual se controla basado en todas las definiciones anteriores

El poder del bicho bola, fue separado del resto de los movimientos del juego por sus características particulares. Principalmente por las reglas relativas a al control sucesivo de los movimientos del juego, hablamos de las reglas “El bicho bola no podrá mover la última pieza que haya movido el adversario” y “La pieza movida por el bicho bola no podrá moverse ni ser movida durante el siguiente turno.”. Reglas que en los momentos iniciales no se presentaban una solución clara, y no fue hasta un punto más sólido del desarrollo que se tubo claro el camino. Además, como esta poder es una característica peculiar en el juego pues no se mueve la propia ficha, sino que manda a moverse a los insectos de su alrededor, no pareció una idea errada separa este comportamiento de los otros movimientos. Para esta particularidad se definirán dos enunciados análogos a los anteriores, `pill_bug_fail_condition` que lista los casos en que no es posible utilizar este poder, y `mov_by_pill_bug` el cual se encarga de actualizar el tablero. Cada vez que se realiza un movimiento a partir del efecto del bicho bola al predicado `dont_mov` se le añade una nueva cláusula que se elimina cuando se termine el turno de oponente. Entre los posibles error que puede reportar al intentar este poder estar:

- 'No hay bicho bola entre las posiciones señaladas’: Para el caso en que no esta un bicho bola adyacente a las posiciones señaladas. También analiza la presencia se un mosquito que tenga adyacente un bicho bola una posición más allá de las marcadas.
- ‘No puede mover insectos apilados’: Cuando el insecto que se intenta desplazar forma parte de una pila formada por los movimientos de un escarabajo o cuando el ejecutor del poder perteneces a una de dichas pilas.
- ‘No puede mover la ultima jugada del oponente’: Cuando se intenta desplazar la ultima jugada del contrario, para esta regla se definió el predicado dinámico `last/3` que se actualiza con cada acción sobre el Hive y en todo momento solo tiene una única cláusula afirmativa.

El desarrollo de la IA, que sepa decidir la mejor jugada para cada situación, estuvo apoyado en el algoritmo de decisión min-max. El algoritmo min-max esta pensado problemas tipo juego, donde un jugador en su turno debe tomar la mejor decision para sí mismo y en el siguiente turno el oponente debe tomar la peor decisión para su oponente. Uno de los problemas que puede tener este algoritmo es la profundidad del árbol de búsqueda, si el juego tiene demasiadas posibilidades entonces el espacio de búsqueda puede llegar a ser demasiado grande. Basadas en estas ideas se desarrollo un predicado de Prolog que dado una profundidad simula paso a paso todos los posibles Hive hasta dicha profundidad. Una vez llegado al tope de la simulación se calcula la densidad entre la cantidad de insectos oponentes que rodean a la reina del jugador de turno y la cantidad de insectos del jugador de turno que rodean a la reina del oponente. A partir de dicho calculo se toma la decisión en cada nivel cual será la jugada óptima, en los niveles que el pertenece a la simulación de las jugadas del jugador de turno se selecciona la jugada que represente la menor densidad y en el caso contrario, en las simulaciones del oponente, se selecciona las jugadas de mayor densidad. De esta manera al terminar la simulación en profundidad se pude escoger la mejor jugada posible con respecto a la profundidad marcada y minimizando el peligro que puede corre su reina y el peligro en que puede poner a la reina del contrario. Para intentas amortiguar el tiempo de ejecución de dicho algoritmo, pues el Hive es un juego con muchísimas posibilidades y a medida que se va avanzando en el juego para profundidades pequeñas el espacio de búsqueda se torna demasiado grande, se definió el predicado dinámico `cache/4` con el objetivo de almacenar al lo largo del juego las distintas decisiones que la IA va tomando. En el predicado `cache` se almacena para un set de ( insecto, jugador, posición ) y un jugador que le toque mover la densidad que se escogió en algún análisis anterior y la lista de movimientos posibles. Así pues, una vez analizada una situación no es necesario volver a simular el juego en profundidad para tomar una decision.
