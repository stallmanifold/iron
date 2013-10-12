
Require Export Iron.Language.SystemF2Effect.Type.Exp.Base.
Require Export Iron.Language.SystemF2Effect.Type.TyEnv.
Require Export Iron.Language.SystemF2Effect.Type.Operator.SubstTT.
Require Export Iron.Language.SystemF2Effect.Type.Relation.FreshT.


(********************************************************************)
Fixpoint mergeT (p1 p2 : nat) (tt : ty)  : ty :=
 match tt with
 | TVar    _            => tt
 | TForall k t          => TForall k (mergeT p1 p2 t)
 | TApp    t1 t2        => TApp (mergeT p1 p2 t1) (mergeT p1 p2 t2)
 | TSum    t1 t2        => TSum (mergeT p1 p2 t1) (mergeT p1 p2 t2)
 | TBot    k            => TBot k
 | TCon0   tc0          => TCon0 tc0
 | TCon1   tc1 t1       => TCon1 tc1 (mergeT p1 p2 t1)
 | TCon2   tc2 t1 t2    => TCon2 tc2 (mergeT p1 p2 t1) (mergeT p1 p2 t2)
 | TCap (TyCapRegion p) => if beq_nat p p2 then TRgn p1 else tt
 end.


Definition mergeTE p1 p2 te := map (mergeT p1 p2) te.
Hint Unfold mergeTE.


(********************************************************************)
Lemma mergeT_wfT
 :  forall n t1 t2 p1 p2
 ,  mergeT p1 p2 t1 = t2
 -> WfT n t1
 -> WfT n t2.
Proof.
 intros. gen n t2.
 induction t1; snorm; inverts H0; rewrite <- H; eauto.
 destruct t. snorm.
Qed.
Hint Resolve mergeT_wfT.


Lemma mergeT_freshT_id
 :  forall p1 p2 t
 ,  freshT p2 t
 -> mergeT p1 p2 t = t.
Proof.
 intros. 
 induction t; snorm; rewritess; auto.
 - destruct t. snorm. nope.
Qed.


Lemma mergeT_substTT
 :  forall ke sp t k p1 p2 ix
 ,  freshT p2 t
 -> KindT ke sp t k
 -> mergeT p1 p2 (substTT ix (TRgn p2) t)
 =  substTT ix (TRgn p1) t.
Proof.
 intros. gen ix ke k.
 induction t; snorm;
  try (inverts H0; espread; eauto).
 - nope.
Qed.


Lemma mergeT_kindT
 :  forall ke sp t k p1 p2
 ,  In (SRegion p1) sp
 -> KindT ke sp t k
 -> KindT ke sp (mergeT p1 p2 t) k.
Proof.
 intros. induction H0; snorm; eauto.
Qed.
Hint Resolve mergeT_kindT.


Lemma mergeT_kindT_chop
 :  forall ke sp t k p1 p2
 ,  In (SRegion p2) sp
 -> KindT ke sp (mergeT p1 p2 t) k
 -> KindT ke sp t k.
Proof.
 intros. gen ke k.
 induction t; intros; snorm; inverts_kind; eauto.

 - eapply KiCon2.
   destruct tc. snorm. inverts H3.
   destruct t1. snorm. 
   + eauto. 
   + destruct tc. snorm. inverts H3. eauto.

 - destruct t; snorm. subst.
   inverts_kind. eauto.
Qed.
Hint Resolve mergeT_kindT_chop.


Lemma mergeTE_rewind
 :  forall p1 p2 te t
 ,  freshT p2 t
 -> mergeTE p1 p2 te :> t
 =  mergeTE p1 p2 (te :> t).
Proof.
 intros.

 have HT1: (t = mergeT p1 p2 t)
  by (symmetry; apply mergeT_freshT_id; auto).
 rewrite HT1 at 1.
 snorm.
Qed.


Lemma mergeT_liftTT_comm
 : forall n d p1 p2 t
 , liftTT n d (mergeT p1 p2 t)
 = mergeT p1 p2 (liftTT n d t).
Proof.
 intros. gen n d.
 induction t; intros; snorm;
  try (solve [f_equal; rewritess; auto]).
 destruct t. snorm.
Qed.
Hint Resolve mergeT_liftTT_comm.


Lemma mergeTE_liftTE_comm
 : forall d p1 p2 ts
 , liftTE d (mergeTE p1 p2 ts)
 = mergeTE p1 p2 (liftTE d ts).
Proof.
 intros.
 induction ts; snorm.
 rewritess. rewrite mergeT_liftTT_comm. auto.
Qed.
Hint Resolve mergeTE_liftTE_comm.


Lemma mergeT_substTT_comm
 : forall d t1 t2 p1 p2
 , substTT d (mergeT p1 p2 t1) (mergeT p1 p2 t2)
 = mergeT p1 p2 (substTT d t1 t2).
Proof.
 intros. gen d t1.
 induction t2; intros; snorm;
  try (solve [f_equal; repeat (rewrite mergeT_liftTT_comm); espread; auto]).
 
 - Case "TCap".
   destruct t. snorm.
Qed.
Hint Resolve mergeT_substTT_comm.


