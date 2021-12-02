% :- use_module(library(http/thread_httpd)).
% :- use_module(library(http/http_dispatch)).
% :- use_module(library(http/http_json)).

% % URL handlers.
% :- http_handler('/', handle_request, []).

% % Calculates a + b.
% solve(_{a:X, b:Y}, _{answer:N}) :-
%     number(X),
%     number(Y),
%     N is X + Y.

% handle_request(Request) :-
%     http_read_json_dict(Request, Query),
%     solve(Query, Solution),
%     reply_json_dict(Solution).

% server(Port) :-
%     http_server(http_dispatch, [port(Port)]).

% :- initialization(server(8000)).


:- use_module(library(http/http_server)).

% run(Port) :- http_listen(Port, [get(/, request_responce)]).
% request_responce(_, Responce) :- 
%     http_status_code(Responce, 200),
%     http_body(Responce, text("Hello!")).

:- initialization(http_server([port(8000)])).

:- http_handler(root(.), 
    http_redirect(moved, location_by_id(home.page))
    ,[]).

:- http_handler(root(home), home_page, []).

home_page(_Request) :- 
    reply_html_page(title('Demo Server'), [h1('Hello word!')]).