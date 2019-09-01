:-module(configuration, [derivation_depth/1
			,experiment_file/2
			,extend_metarules/1
			,metarule/2
			,metarule/3
			,metarule/4
			,metarule/5
			,recursion_depth_limit/2
			,recursive_reduction/1
			,resolutions/1
			,theorem_prover/1
			]).

:-user:use_module(src(experiment_file)).
:-reexport(lib(program_reduction/reduction_configuration), except([derivation_depth/1
								  ,resolutions/1])).
:-reexport(lib(evaluation/evaluation_configuration)).
:-reexport(lib/sampling/sampling_configuration).


% Body literals of H(2,2) metarules.
:-dynamic m/1
         ,m/2
         ,m/3
	 ,m/4
	 ,m/5.

:-multifile m/1
           ,m/2
	   ,m/3
	   ,m/4
	   ,m/5.

% Allows experiment files to define their own, special metarules.
% BUG: Actually, this doesn't work- module quantifiers, again.
% Needs fixing.
:-multifile metarule/2
           ,metarule/3
           ,metarule/4
	   ,metarule/5.

/* Debug levels */
%:-debug(depth). % Debug number of clauses and invented predicates.
%:-debug(learn). % Debug learning steps.
%:-debug(top). % Debug Top program construction.
%:-debug(reduction). % Debug Top program construction.
%:-debug(episodic). % Debug episodic learning.


%!	derivation_depth(?Depth) is semidet.
%
%	Maximum depth of derivation branches.
%
%	Used in program_reduction module with solve_to_depth/3 and
%	solve_to_limit/4 meta-interpreters.
%
%derivation_depth(3).
%derivation_depth(5).
%derivation_depth(8).
derivation_depth(9).
%derivation_depth(10).
%derivation_depth(20).
%derivation_depth(5000).


%!	experiment_file(?Path,?Module) is semidet.
%
%	The Path and Module name of an experiment file.
%
experiment_file('data/examples/kinship/tiny_kinship.pl',tiny_kinship).
%experiment_file('data/examples/grammars/anbn.pl',anbn).
%experiment_file('data/examples/abduced.pl',abduced).
%experiment_file('data/examples/special_metarules.pl',special_metarules).
%experiment_file('data/mtg/mtg_fragment.pl',mtg_fragment).
%experiment_file('data/examples/kinship/kinship.pl',kinship).


%!	extend_metarules(?Bool) is semidet.
%
%	Whether to extend the metarules in a MIL problem.
%
extend_metarules(false).


%!	metarule(?Id,?P,?Q) is semidet.
%!	metarule(?Id,?P,?Q,?R) is semidet.
%
%	An encapsulated metarule.
%
%	@tbd This representation does not define constraints. For the
%	time being this doesn't seem to be necessary but a complete
%	representation will need to include constraints.
%
metarule(abduce,P,X,Y):- m(P,X,Y).
metarule(unit,P):- m(P,_X,_Y).
metarule(projection,P,Q):- m(P,X,X), m(Q,X).
metarule(identity,P,Q):- m(P,X,Y), m(Q,X,Y).
metarule(inverse,P,Q):- m(P,X,Y), m(Q,Y,X).
metarule(chain,P,Q,R):- m(P,X,Y), m(Q,X,Z), m(R,Z,Y).
metarule(tailrec,P,Q,P):- m(P,X,Y), m(Q,X,Z), m(P,Z,Y).
metarule(precon,P,Q,R):- m(P,X,Y), m(Q,X), m(R,X,Y).
metarule(postcon,P,Q,R):- m(P,X,Y), m(Q,X,Y), m(R,Y).
metarule(switch,P,Q,R):- m(P,X,Y), m(Q,X,Z), m(R,Y,Z).


%!	recursion_depth_limit(?Purpose,?Limit) is semidet.
%
%	Recursion depth Limit for the given Purpose.
%
%	Limit is an integer, which is passed as
%	the second argument to call_with_depth_limit/3 in order to
%	limit recursion in the listed Purpose.
%
%	Known purposes are as follows:
%
%	* episodic_learning: Limits recursion during Top program
%	construction in episodic learning.
%
recursion_depth_limit(episodic_learning,100).


%!	recursive_reduction(?Bool) is semidet.
%
%	Whether to reduce the Top program recursively or not.
%
%	Setting Bool to true enables recursie reduction of the Top
%	program. Recursive reduction means that the result of each
%	reduction step is given as input to the reduction algorithm in
%	the next step (also known as "doing the feedbacksies").
%
%	Recursive reduction can result in a stronger reduction in less
%	time, with a lower setting for resolutions/1 (in fact, the same
%	amount of reduction can take less time exactly because the
%	resolutions/1 setting can be set to a lower value).
%
%	Recursive reduction is more useful when the Top program is large
%	and many resolution steps are required to remove all redundancy
%	from it.
%
recursive_reduction(false).


%!	resolutions(?Resolutions) is semidet.
%
%	Maximum number of resolutions.
%
%	Used with solve_to_depth/3.
%
%resolutions(500_000_000_000).
%resolutions(20_500_000).
%resolutions(10_500_000).
%resolutions(5_500_000).
%resolutions(500_000).
%resolutions(250_000).
%resolutions(30_000).
%resolutions(10_000).
resolutions(5000).
%resolutions(100).
%resolutions(15).
%resolutions(0).


%!	theorem_prover(?Algorithm) is semidet.
%
%	Theorem proving Algorithm to use in Top program construction.
%
%	Algorithm is one of: [resolution, tp].
%
%	With option resolution, the Top program is constructed in a
%	top-down manner, using SLD resolution.
%
%	With option tp, the Top program is constructed in a bottom-up
%	manner, using a TP operator.
%
%	Option resolution is faster because it hands off to the Prolog
%	interpreter. On the other hand, it can get lost in recursion,
%	especially when a problem has left-recursions (although this
%	doesn't quite seem to happen in practice).
%
%	Option tp is slower because it's implemented in Prolog and it's
%	not terribly optimised either. The trade-off is that it's
%	guaranteed to terminate and runs in polynomial time, at least
%	for definite programs (but then, there are no guarantees outside
%	of definite programs).
%
%	More impotantly, option tp can be used to enable predicate
%	invention, although this is not yet implemented.
%
%	Note also that the TP operator only works for datalog definite
%	programs.
%
theorem_prover(resolution).
%theorem_prover(tp).


% Loads the current experiment file in the Swi-Prolog IDE when the
% configuration is changed.
%
% It is perfectly safe to remove this directive.
%
%:-experiment_file(P,_)
%  ,edit(P).


% This line ensures the experiment file set in the configuration option
% experiment_file/2 is always updated when the configuration module is
% changed and reloaded. Don't remove it.
%
% DO NOT REMOVE THIS LINE!
:-experiment_file:reload.
