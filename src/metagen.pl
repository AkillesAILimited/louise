:-module(metagen, [metarule_coterie/4
		  ,metarule_kindred/3
		  ,metarule_bloodline/3
		  ,metarule_generation/3
		  ]).

/** <module> Predicates for metarule generation.

Predicates in this module automatically generate metarules in the H2n
language of metarules with up to n body literals of arity 2.

Motivation
----------

Meta-Interpretive Learning systems like Louise rely on a set of
metarules to restrict the language of hypotheses: each clause in
a hypothesis learned by Louise is an instance of a metarule given as
part of the MIL problem.

Metarules for a MIL problem must be provided by the user. This can be an
onerous requirement, demanding that the user has an insight into the
_structure_ of a hypothesis to be learned. The current module provides
predicates that alleviate the burden of metarule selection by
automatically generating sets of metarules. In particular, predicates in
this module generate instances of the H22 _Chain_, _Inverse_ and
_Identity_ metarules and their H2n _extensions_.

==
% H22 Chain, Inverse and Identity (encapsulated):

m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(inverse,A,B):-m(A,C,D),m(B,D,C).
m(identity,A,B):-m(A,C,D),m(B,C,D).
==

_Chain_, _Inverse_ and _Identity_ are second-order generalisations of
transitivity, symmetry and identity (in MIL literature, _Identity_ is
often named _Base_). While transitivity, symmetry and identity are
relations of 0-th order objects, their second-order generalisations are
relations _of relations_. In theory, these three metarules should
suffice to define any equivalence relation over the predicates in a MIL
problem (i.e. the target predicate and the background knowledge).

_Chain_ and _Inverse_ are also special in that they are sufficient to
derive each other H22 metarule by _unfolding_. Additionally, _Inverse_
and the H2n _Chain_ are sufficient to derive each other H2n metarule by
unfolding.

To "unfold" two metarules, M1 and M2, is to unfiy each literal, L1, of
M1 with the head literal of M2 and replace L1 in the body of L1 with the
body literals of M2. This module also provides predicates to extend
metarules by unfolding.

The combination of automatic metarule generation with extension by
unfolding provides a set of metarules sufficient to successfully learn a
broad range of hypotheses without having to "hand-craft" metarules.

In principle, the H22 language of second-order definite datalog (i.e.
second order definite clauses with no functions of arity more than 0)
is sufficient to express a Universal Turing Machine and is decidable
given a finite predicate and constant signature. Metarules in H22 can be
"derived-back" from H22 _Inverse_ and H2n _Chain_ by predicate
invention, so the ability to generate H2n instances of _Chain_ and
_Inverese_ of any length n should suffice to learn any target theory.

In practice, what can and cannot be learned using the metarules
generated by predicates in this module will depend very much on the
background knowledge. For example, given that all literals of H2n
metarules have arity exactly 2, definitions of background knowledge
predicates with arity other than 2 will not be usable to form a
hypothesis.

Below we introduce some terminology regarding sets of metarules and give
examples of their generation by predicates defined in this module.

Terminology
-----------

An _extension_ of a metarule Mn is a metarule Mn+k such that Mn+k has k
more literals than Mn. Mn is the _original_ or _initial_ metarule and
Mn+k _extends_ Mn.

==
% Chain and one of its extensions with 1 extra literal.
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(chain,A,B,C,D):-m(A,E,F),m(B,E,G),m(C,G,H),m(D,H,F).
==

The process of extending one or more metarules is _metarule extension_.
In this module, metarule extension is performed in two ways: by
unfolding; and by generating extensions of a given length directly.

Metarule generation
-------------------

We will refer to sets of metarule extensions of a given length as
_generations_ of metarules.

A _metarule generation_ is a tuple, [{M11,..,M1k},n,{E1n,...,Ekn}]
where:

  * {M11,...,M1k} is a set of metarules in the first generation called
  the _progenitors_.

  * n > 0 is a positive integer, the _generation_ of the
  childer (defined next).

  * {E1n,...,Ekn} is a set of extensions of each of the progenitors,
  called the progenitor's _childer_ and such that each n'th generation
  childe has n-1 more literals than its progenitor.

Note that if n=1 the childer are the progenitors themselves. For
predicates in this module, the progranitors are always one or more of
the H22 instances of _Chain_, _Inverse_ and _Identity_.

We will then speak of the "n'th-generation childer" of some set of
progenitors, or just "the n'th generation", where the progenitors are
clear from the context.

==
% The 2nd-generation childer of Chain and Inverse:

?- metarule_generation(2,[chain,inverse],_MS), print_clauses(_MS).
m(chain,A,B,C,D):-m(A,E,F),m(B,E,G),m(C,G,H),m(D,H,F).
m(inverse,A,B,C):-m(A,D,E),m(B,E,D),m(C,D,E).
true.
==

A set consisting of a progenitor and each of its childer up to some
finite generation, n, is a _bloodline_.

==
% A bloodline of Chain up to the 3d generation:

?- metarule_bloodline(3,chain,_MS), print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(chain,A,B,C,D):-m(A,E,F),m(B,E,G),m(C,G,H),m(D,H,F).
m(chain,A,B,C,D,E):-m(A,F,G),m(B,F,H),m(C,H,I),m(D,I,J),m(E,J,G).
true.
==

A set of bloodlines is a _kindred_.

==
% The kindred of Chain and Inverse up to the 2nd generation:

?- metarule_kindred(2,[chain,inverse],_MS), print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(inverse,A,B):-m(A,C,D),m(B,D,C).
m(chain,A,B,C,D):-m(A,E,F),m(B,E,G),m(C,G,H),m(D,H,F).
m(inverse,A,B,C):-m(A,D,E),m(B,E,D),m(C,D,E).
true.
==

A set of childer of generations n to m and possibly of different
progenitors is a _coterie_.

==
% A coterie of childer of Chain, Invese and Identity of the 2nd, 3d and
% 4th generations:

?- metarule_coterie(2,4,[chain,inverse,identity],_MS), print_clauses(_MS).
m(chain,A,B,C,D):-m(A,E,F),m(B,E,G),m(C,G,H),m(D,H,F).
m(inverse,A,B,C):-m(A,D,E),m(B,E,D),m(C,D,E).
m(identity,A,B,C):-m(A,D,E),m(B,D,E),m(C,D,E).
m(chain,A,B,C,D,E):-m(A,F,G),m(B,F,H),m(C,H,I),m(D,I,J),m(E,J,G).
m(inverse,A,B,C,D):-m(A,E,F),m(B,F,E),m(C,E,F),m(D,F,E).
m(identity,A,B,C,D):-m(A,E,F),m(B,E,F),m(C,E,F),m(D,E,F).
m(chain,A,B,C,D,E,F):-m(A,G,H),m(B,G,I),m(C,I,J),m(D,J,K),m(E,K,L),m(F,L,H).
m(inverse,A,B,C,D,E):-m(A,F,G),m(B,G,F),m(C,F,G),m(D,G,F),m(E,F,G).
m(identity,A,B,C,D,E):-m(A,F,G),m(B,F,G),m(C,F,G),m(D,F,G),m(E,F,G).
true.
==

Note that there is no special predicate to generate progenitors. Each of
the predicates shown above will generate the progenitors of a set if "1"
is given as the number of the earliest (or only) generation to be
produced. metarule_bloodline/3 and metarule_kindred/3 always include
the progenitors of a set in their output.

For example, each of the queries in the following listing will generate
all three 1st-generation instances of _Chain_, _Inverse_ and _Identity_:

==
% 1st-generation metarules

?- metarule_generation(1, [chain,inverse,identity], _MS), print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(inverse,A,B):-m(A,C,D),m(B,D,C).
m(identity,A,B):-m(A,C,D),m(B,C,D).
true.

?- member(_M, [chain,inverse,identity]), metarule_bloodline(1,_M,_MS),print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
true ;
m(inverse,A,B):-m(A,C,D),m(B,D,C).
true ;
m(identity,A,B):-m(A,C,D),m(B,C,D).
true.

?- metarule_kindred(1,[chain,inverse,identity],_MS),print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(inverse,A,B):-m(A,C,D),m(B,D,C).
m(identity,A,B):-m(A,C,D),m(B,C,D).
true.

?- metarule_coterie(1,1,[chain,inverse,identity],_MS),print_clauses(_MS).
m(chain,A,B,C):-m(A,D,E),m(B,D,F),m(C,F,E).
m(inverse,A,B):-m(A,C,D),m(B,D,C).
m(identity,A,B):-m(A,C,D),m(B,C,D).
true.
==

*/


%!	metarule_coterie(+Minimum,+Maximum,+Progenitors,-Coterie) is
%!	det.
%
%	Generate a Coterie of the given Minimum and Maximum generations.
%
%	Minimum and Maximum are non-zero positive integers, the earliest
%	and latest generation of childer in Coterie. Progenitors is a
%	list of atoms, the metarule identities of the progenitors of
%	the coterie. Coterie is a list of encapsulated metarules, the
%	childer of the listed Progenitors in each generation from
%	Minimum to Maximum.
%
metarule_coterie(I,K,IDs,MS):-
	findall(M
	       ,(between(I,K,I_)
		,member(Id,IDs)
		,generation_metarule(I_,Id,M)
		)
	       ,MS).


%!	metarule_kindred(+Maximum,+Progenitors,-Kindred) is det.
%
%	Generate a Kindred of generations from 1 to Maximum.
%
%	Maximum is a nonzero positive integer, the highest generation of
%	childer in Kindred. Progenitors is a list of atoms, the metarule
%	ids of the progenitors in the kindred. Kindred is a list of
%	encapsulated metarules, the listed Progenitors and their
%	childer in each generation up to Maximum.
%
metarule_kindred(I,IDs,MS):-
	findall(M
	       ,(between(1,I,I_)
		,member(Id,IDs)
		,generation_metarule(I_,Id,M)
		)
	       ,MS).



%!	metarule_bloodline(+Max_Generation,+Progenitor,-Bloodline) is
%!	det.
%
%	Generate a Bloodline of Progenitor up to Max_Generation.
%
%	Max_Generation is a nonzero positive integer, the highest
%	generation of childer in Bloodline. Progenitor is an atom, the
%	metarule id of the bloodline's progenitor. Bloodline is a list
%	of encapsulated metarules, an instance of Progenitor and its
%	childer in each generation from the second to Max_Generation.
%
metarule_bloodline(I,P,MS):-
	findall(M
	       ,(between(1,I,I_)
		,generation_metarule(I_,P,M)
		)
	       ,MS).



%!	metarule_generation(+Generation,+Progenitors,-Childer)is det.
%
%	Generate all Childer of Progenitors in a Generation.
%
%	Generation is a nonzero positive integer, the generation.
%	Progenitors is a list of atoms, the metarule ids of the
%	progenitors in the generation. Childer is a list of encapsulated
%	metarules, the childer in the generation.
%
%	If Generation is 1, the Childer are the encapsulated instances
%	of the Progenitors.
%
metarule_generation(I,IDs,MS):-
	findall(M
	       ,(member(Id,IDs)
		,generation_metarule(I,Id,M)
		)
	       ,MS).



%!	generation_metarule(+Generation,+Id,-Metarule) is semidet.
%
%	Generate a Metarule of the given Generation.
%
%	A metarule generation is a tuple, (M1,I,Mi) where M1 is a
%	metarule, called the _progenitor_ of the generation, i > 0 is
%	the generation, a positive integer, and Mi is an extension of M1
%	with n+i (head and body) literals, where n is the number of body
%	literals in M1.
%
%	For example, the length of a metarule of generation n is n + 1
%	if the metarule is an extension of inverse or identity and n + 2
%	if the metarule is chain.
%
generation_metarule(I,chain,M):-
	I_ is I + 2
	,encapsulated_metarule(chain,I_,M).
generation_metarule(I,inverse,M):-
	succ(I, I_)
	,encapsulated_metarule(inverse,I_,M).
generation_metarule(I,identity,M):-
	succ(I, I_)
	,encapsulated_metarule(identity,I_,M).


%!	encapsulated_metarule(+Id,+Literals,-Metarule) is semidet.
%
%	Generate an encapsulated Metarule.
%
encapsulated_metarule(Id,N,(A:-H,B)):-
	generate_metarule(Id,N,H:-B)
	,existential_vars((H,B),[],Es)
	%,atomic_list_concat([Id,N],'_',Id_N)
	%,A =.. [m,Id_N|Es]
	,A =.. [m,Id|Es].


%!	existential_vars(+Literals,+Acc,-Variables) is det.
%
%	Collect existentially qualified variables in a set of Literals.
%
existential_vars((L,Ls),Acc,Bind):-
	L =.. [m,P|_]
	,existential_vars(Ls,[P|Acc],Bind).
existential_vars((L),Acc,Es):-
	L \== (_,_)
	,L =.. [m,P|_]
	,reverse([P|Acc],Es).



%!	generate_metarule(+Id,+Literals,-Metarule) is semidet.
%
%	Generate a Metarule with the given number of Literals.
%
%	Id is the name of the metarule to create, one of: [chain,
%	inverse, identity].
%
%	Note that it doesn't make sense to start chain with fewer than 3
%	Literals or identity with fewer than 2.
%
generate_metarule(chain,N,_):-
	N < 3
	,!
	,fail.
generate_metarule(Id,N,H_:-B_):-
	N_ is N - 1
	,head_literal(Id,N_,Vs,H)
	,add_literals(Id,1,N,Vs,[H],Ls)
	,once(list_tree(Ls,T))
	,varnumbers(T,(H_,B_)).


%!	head_literal(+Id,+Literals,+Vars,-Head) is semidet.
%
%	Create a Head literal for the named metarule.
%
head_literal(chain,N,[N,0,1],H):-
	Max is N
	,new_literal([N,0,Max],H).
head_literal(Id,_N,[1,0,1],H):-
	memberchk(Id,[inverse,identity])
	,new_literal([1,0,1],H).


%!	new_literal(+Variables,-Literal) is det.
%
%	Create a new literal from the given set of Variables.
%
new_literal([P,A,B],m('$VAR'(Q),'$VAR'(A),'$VAR'(B))):-
	predicate_variable(P,Q).


%!	predicate_variable(+Current,-New) is det.
%
%	Create a new existentially quantified second order Variable.
%
predicate_variable(P,Q):-
	succ(P,Q).


%!	add_literals(+Id,+Current,+Length,+Vars,+Acc,-Literals) is
%!	semidet.
%
%	Generate body Literals for the named metarule.
%
add_literals(_Id,N,N,_Vs,Acc,Ls):-
	!
	,reverse(Acc,Ls).
add_literals(Id,C,N,Vs,Acc,Bind):-
	new_variables(Id,C,Vs,Vs_)
	,new_literal(Vs_,L)
	,succ(C,C_)
	,add_literals(Id,C_,N,Vs_,[L|Acc],Bind).


%!	new_variables(+Id,+Current,+Vars,-New) is semidet.
%
%	Generate variables for a new literal added to a metarule.
%
new_variables(chain,1,[P,A,B],[Q,A,B]):-
% Chain must start with P(A,B):- Q(A,B)
	predicate_variable(P,Q).
new_variables(inverse,1,[P,A,B],[Q,B,A]):-
% Inverse must start with P(A,B):- Q(B,A)
	predicate_variable(P,Q).
new_variables(chain,I,[P,A,B],[Q,B,C]):-
	I > 1
	,A < B
	,predicate_variable(P,Q)
	,succ(B,C).
new_variables(inverse,I,[P,A,B],[Q,B,A]):-
	I > 1
	,predicate_variable(P,Q).
new_variables(identity,_,[P,A,B],[Q,A,B]):-
% Every literal in identity is P(A,B), Q(A,B), R(A,B) ...
	predicate_variable(P,Q).
