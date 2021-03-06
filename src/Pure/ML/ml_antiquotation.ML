(*  Title:      Pure/ML/ml_antiquotation.ML
    Author:     Makarius

ML antiquotations.
*)

signature ML_ANTIQUOTATION =
sig
  val declaration: binding -> 'a context_parser ->
    (Token.src -> 'a -> Proof.context -> ML_Context.decl * Proof.context) ->
    theory -> theory
  val inline: binding -> string context_parser -> theory -> theory
  val value: binding -> string context_parser -> theory -> theory
end;

structure ML_Antiquotation: ML_ANTIQUOTATION =
struct

(* define antiquotations *)

fun declaration name scan body =
  ML_Context.add_antiquotation name
    (fn src => fn orig_ctxt =>
      let val (x, _) = Token.syntax scan src orig_ctxt
      in body src x orig_ctxt end);

fun inline name scan =
  declaration name scan (fn _ => fn s => fn ctxt => (K ("", s), ctxt));

fun value name scan =
  declaration name scan (fn _ => ML_Context.value_decl (Binding.name_of name));


(* basic antiquotations *)

val _ = Theory.setup
 (declaration (Binding.make ("here", \<^here>)) (Scan.succeed ())
    (fn src => fn () =>
      ML_Context.value_decl "position" (ML_Syntax.print_position (#2 (Token.name_of_src src)))) #>

  inline (Binding.make ("make_string", \<^here>)) (Args.context >> K ML_Pretty.make_string_fn) #>

  value (Binding.make ("binding", \<^here>))
    (Scan.lift (Parse.input Args.embedded) >> (ML_Syntax.make_binding o Input.source_content)) #>

  value (Binding.make ("cartouche", \<^here>))
    (Scan.lift Args.cartouche_input >> (fn source =>
      "Input.source true " ^ ML_Syntax.print_string (Input.text_of source) ^ " " ^
        ML_Syntax.atomic (ML_Syntax.print_range (Input.range_of source)))) #>

  inline (Binding.make ("verbatim", \<^here>))
    (Scan.lift Args.embedded >> ML_Syntax.print_string));

end;
