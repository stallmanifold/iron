
Require Export Iron.Language.SystemF2Cap.Type.Operator.LiftTT.
Require Export Iron.Language.SystemF2Cap.Type.Relation.SubsT.


(* If one type subsumes another, and we substitute some third
   type into both, then the results are also subsumptive.

   NOTE: The more general form where t1 and t2 are open should also
         be true, but we don't need it for the main proofs.
*)
Lemma subsT_closed_liftT_liftT
 :  forall sp t1 t2 k d
 ,  SubsT nil sp t1 t2 k
 -> SubsT nil sp (liftTT 1 d t1) (liftTT 1 d t2) k.
Proof.
 intros.
 have (ClosedT t1).
 have (ClosedT t2).
 rrwrite (liftTT 1 d t1 = t1).
 rrwrite (liftTT 1 d t2 = t2).
 auto.
Qed.
Hint Resolve subsT_closed_liftT_liftT. 
