
Require Export Iron.Language.SystemF2Effect.Store.Bind.
Require Export Iron.Language.SystemF2Effect.Store.TypeB.


(* Well typed store.
   All bindings are well typed. *)
Definition STORET (se: stenv) (sp: stprops) (ss: store)
 := Forall2 (TYPEB nil nil se sp) ss se.
Hint Unfold STORET.


(* Weaken store properties in store typing judgement. *)
Lemma storet_weak_stprops
 :  forall se sp ss p
 ,  STORET se sp ss
 -> STORET se (SRegion p <: sp) ss.
Proof.
 intros.
 unfold STORET in *.
 eapply Forall2_impl.
  intros. eapply typeb_stprops_snoc. eauto.
 auto.
Qed.
Hint Resolve storet_weak_stprops.


(* All region handles in store bindings are present 
   in the store properties. *)
Lemma storet_handles_in_stprops
 :  forall se sp ss
 ,  STORET se sp ss
 -> Forall (fun s => forall p
                  ,  regionOfStBind s = p 
                  -> In (SRegion p) sp) 
           ss.
Proof.
 intros.
 snorm.
 unfold STORET in *.
 have (exists ix, get ix ss = Some x).
  dest ix.
 have (exists t, TYPEB nil nil se sp x t).
  dest t.
 inverts H3.
 - snorm. subst. inverts_kind. auto.
 - snorm. subst. inverts_kind. auto.
Qed.


(* Extended store is well typed under extended store environment *)
Lemma storet_snoc
 :  forall se sp ss r1 v1 t2
 ,  KindT  nil sp (TRgn r1) KRegion
 -> TYPEV  nil nil se sp v1 t2
 -> STORET                       se  sp                   ss
 -> STORET (TRef (TRgn r1) t2 <: se) sp (StValue r1 v1 <: ss).
Proof.
 intros.
 set (tRef' := TRef (TRgn r1) t2).

 assert (TYPEB nil nil (tRef' <: se) sp (StValue r1 v1) tRef').
 { apply TbValue; auto.
   - apply typev_stenv_snoc.
     subst tRef'.
     assert (ClosedT t2).
      rrwrite (0 = @length ki nil).
      apply (kind_wfT nil sp t2 KData).

      (* NOTE: This one has to be done manually to instantiate existentials *)
      apply (typex_kind_type nil nil se sp (XVal v1) t2 (TBot KEffect)).
       auto. auto. auto.
 }
     
 assert (Forall2 (TYPEB nil nil (tRef' <: se) sp) ss se).
 { lets D: (@Forall2_impl stbind ty) 
                (TYPEB nil nil se sp) 
                (TYPEB nil nil (tRef' <: se) sp)
                ss se H1.
   intros.
   apply typeb_stenv_snoc.
    auto.
    subst tRef'. eauto.
   auto. 
 }
 auto.
Qed.
Hint Resolve storet_snoc.
