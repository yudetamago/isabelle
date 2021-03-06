section%important \<open>Continuity of the indefinite integral; improper integral theorem\<close>

theory "Improper_Integral"
  imports Equivalence_Lebesgue_Henstock_Integration
begin

subsection%important \<open>Equiintegrability\<close>

text\<open>The definition here only really makes sense for an elementary set. 
     We just use compact intervals in applications below.\<close>

definition%important equiintegrable_on (infixr "equiintegrable'_on" 46)
  where "F equiintegrable_on I \<equiv>
         (\<forall>f \<in> F. f integrable_on I) \<and>
         (\<forall>e > 0. \<exists>\<gamma>. gauge \<gamma> \<and>
                    (\<forall>f \<D>. f \<in> F \<and> \<D> tagged_division_of I \<and> \<gamma> fine \<D>
                          \<longrightarrow> norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral I f) < e))"

lemma equiintegrable_on_integrable:
     "\<lbrakk>F equiintegrable_on I; f \<in> F\<rbrakk> \<Longrightarrow> f integrable_on I"
  using equiintegrable_on_def by metis

lemma equiintegrable_on_sing [simp]:
     "{f} equiintegrable_on cbox a b \<longleftrightarrow> f integrable_on cbox a b"
  by (simp add: equiintegrable_on_def has_integral_integral has_integral integrable_on_def)
    
lemma equiintegrable_on_subset: "\<lbrakk>F equiintegrable_on I; G \<subseteq> F\<rbrakk> \<Longrightarrow> G equiintegrable_on I"
  unfolding equiintegrable_on_def Ball_def
  by (erule conj_forward imp_forward all_forward ex_forward | blast)+

lemma%important equiintegrable_on_Un:
  assumes "F equiintegrable_on I" "G equiintegrable_on I"
  shows "(F \<union> G) equiintegrable_on I"
  unfolding equiintegrable_on_def
proof%unimportant (intro conjI impI allI)
  show "\<forall>f\<in>F \<union> G. f integrable_on I"
    using assms unfolding equiintegrable_on_def by blast
  show "\<exists>\<gamma>. gauge \<gamma> \<and>
            (\<forall>f \<D>. f \<in> F \<union> G \<and>
                   \<D> tagged_division_of I \<and> \<gamma> fine \<D> \<longrightarrow>
                   norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral I f) < \<epsilon>)"
         if "\<epsilon> > 0" for \<epsilon>
  proof -
    obtain \<gamma>1 where "gauge \<gamma>1"
      and \<gamma>1: "\<And>f \<D>. f \<in> F \<and> \<D> tagged_division_of I \<and> \<gamma>1 fine \<D>
                    \<Longrightarrow> norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral I f) < \<epsilon>"
      using assms \<open>\<epsilon> > 0\<close> unfolding equiintegrable_on_def by auto
    obtain \<gamma>2 where  "gauge \<gamma>2"
      and \<gamma>2: "\<And>f \<D>. f \<in> G \<and> \<D> tagged_division_of I \<and> \<gamma>2 fine \<D>
                    \<Longrightarrow> norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral I f) < \<epsilon>"
      using assms \<open>\<epsilon> > 0\<close> unfolding equiintegrable_on_def by auto
    have "gauge (\<lambda>x. \<gamma>1 x \<inter> \<gamma>2 x)"
      using \<open>gauge \<gamma>1\<close> \<open>gauge \<gamma>2\<close> by blast
    moreover have "\<forall>f \<D>. f \<in> F \<union> G \<and> \<D> tagged_division_of I \<and> (\<lambda>x. \<gamma>1 x \<inter> \<gamma>2 x) fine \<D> \<longrightarrow>
          norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral I f) < \<epsilon>"
      using \<gamma>1 \<gamma>2 by (auto simp: fine_Int)
    ultimately show ?thesis
      by (intro exI conjI) assumption+
  qed
qed


lemma equiintegrable_on_insert:
  assumes "f integrable_on cbox a b" "F equiintegrable_on cbox a b"
  shows "(insert f F) equiintegrable_on cbox a b"
  by (metis assms equiintegrable_on_Un equiintegrable_on_sing insert_is_Un)


text\<open> Basic combining theorems for the interval of integration.\<close>

lemma equiintegrable_on_null [simp]:
   "content(cbox a b) = 0 \<Longrightarrow> F equiintegrable_on cbox a b"
  apply (auto simp: equiintegrable_on_def)
  by (metis gauge_trivial norm_eq_zero sum_content_null)


text\<open> Main limit theorem for an equiintegrable sequence.\<close>

theorem%important equiintegrable_limit:
  fixes g :: "'a :: euclidean_space \<Rightarrow> 'b :: banach"
  assumes feq: "range f equiintegrable_on cbox a b"
      and to_g: "\<And>x. x \<in> cbox a b \<Longrightarrow> (\<lambda>n. f n x) \<longlonglongrightarrow> g x"
    shows "g integrable_on cbox a b \<and> (\<lambda>n. integral (cbox a b) (f n)) \<longlonglongrightarrow> integral (cbox a b) g"
proof%unimportant -
  have "Cauchy (\<lambda>n. integral(cbox a b) (f n))"
  proof (clarsimp simp add: Cauchy_def)
    fix e::real
    assume "0 < e"
    then have e3: "0 < e/3"
      by simp
    then obtain \<gamma> where "gauge \<gamma>"
         and \<gamma>: "\<And>n \<D>. \<lbrakk>\<D> tagged_division_of cbox a b; \<gamma> fine \<D>\<rbrakk>
                       \<Longrightarrow> norm((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f n x) - integral (cbox a b) (f n)) < e/3"
      using feq unfolding equiintegrable_on_def
      by (meson image_eqI iso_tuple_UNIV_I)
    obtain \<D> where \<D>: "\<D> tagged_division_of (cbox a b)" and "\<gamma> fine \<D>"  "finite \<D>"
      by (meson \<open>gauge \<gamma>\<close> fine_division_exists tagged_division_of_finite)
    with \<gamma> have \<delta>T: "\<And>n. dist ((\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x)) (integral (cbox a b) (f n)) < e/3"
      by (force simp: dist_norm)
    have "(\<lambda>n. \<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x) \<longlonglongrightarrow> (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R g x)"
      using \<D> to_g by (auto intro!: tendsto_sum tendsto_scaleR)
    then have "Cauchy (\<lambda>n. \<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x)"
      by (meson convergent_eq_Cauchy)
    with e3 obtain M where
      M: "\<And>m n. \<lbrakk>m\<ge>M; n\<ge>M\<rbrakk> \<Longrightarrow> dist (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f m x) (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x)
                      < e/3"
      unfolding Cauchy_def by blast
    have "\<And>m n. \<lbrakk>m\<ge>M; n\<ge>M;
                 dist (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f m x) (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x) < e/3\<rbrakk>
                \<Longrightarrow> dist (integral (cbox a b) (f m)) (integral (cbox a b) (f n)) < e"
       by (metis \<delta>T dist_commute dist_triangle_third [OF _ _ \<delta>T])
    then show "\<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. dist (integral (cbox a b) (f m)) (integral (cbox a b) (f n)) < e"
      using M by auto
  qed
  then obtain L where L: "(\<lambda>n. integral (cbox a b) (f n)) \<longlonglongrightarrow> L"
    by (meson convergent_eq_Cauchy)
  have "(g has_integral L) (cbox a b)"
  proof (clarsimp simp: has_integral)
    fix e::real assume "0 < e"
    then have e2: "0 < e/2"
      by simp
    then obtain \<gamma> where "gauge \<gamma>"
      and \<gamma>: "\<And>n \<D>. \<lbrakk>\<D> tagged_division_of cbox a b; \<gamma> fine \<D>\<rbrakk>
                    \<Longrightarrow> norm((\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x) - integral (cbox a b) (f n)) < e/2"
      using feq unfolding equiintegrable_on_def
      by (meson image_eqI iso_tuple_UNIV_I)
    moreover
    have "norm ((\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R g x) - L) < e"
              if "\<D> tagged_division_of cbox a b" "\<gamma> fine \<D>" for \<D>
    proof -
      have "norm ((\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R g x) - L) \<le> e/2"
      proof (rule Lim_norm_ubound)
        show "(\<lambda>n. (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R f n x) - integral (cbox a b) (f n)) \<longlonglongrightarrow> (\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R g x) - L"
          using to_g that L
          by (intro tendsto_diff tendsto_sum) (auto simp: tag_in_interval tendsto_scaleR)
        show "\<forall>\<^sub>F n in sequentially.
                norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f n x) - integral (cbox a b) (f n)) \<le> e/2"
          by (intro eventuallyI less_imp_le \<gamma> that)
      qed auto
      with \<open>0 < e\<close> show ?thesis
        by linarith
    qed
    ultimately
    show "\<exists>\<gamma>. gauge \<gamma> \<and>
             (\<forall>\<D>. \<D> tagged_division_of cbox a b \<and> \<gamma> fine \<D> \<longrightarrow>
                  norm ((\<Sum>(x,K)\<in>\<D>. content K *\<^sub>R g x) - L) < e)"
      by meson
  qed
  with L show ?thesis
    by (simp add: \<open>(\<lambda>n. integral (cbox a b) (f n)) \<longlonglongrightarrow> L\<close> has_integral_integrable_integral)
qed


lemma%important equiintegrable_reflect:
  assumes "F equiintegrable_on cbox a b"
  shows "(\<lambda>f. f \<circ> uminus) ` F equiintegrable_on cbox (-b) (-a)"
proof%unimportant -
  have "\<exists>\<gamma>. gauge \<gamma> \<and>
            (\<forall>f \<D>. f \<in> (\<lambda>f. f \<circ> uminus) ` F \<and> \<D> tagged_division_of cbox (- b) (- a) \<and> \<gamma> fine \<D> \<longrightarrow>
                   norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral (cbox (- b) (- a)) f) < e)"
       if "gauge \<gamma>" and
           \<gamma>: "\<And>f \<D>. \<lbrakk>f \<in> F; \<D> tagged_division_of cbox a b; \<gamma> fine \<D>\<rbrakk> \<Longrightarrow>
                     norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral (cbox a b) f) < e" for e \<gamma>
  proof (intro exI, safe)
    show "gauge (\<lambda>x. uminus ` \<gamma> (-x))"
      by (metis \<open>gauge \<gamma>\<close> gauge_reflect)
    show "norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R (f \<circ> uminus) x) - integral (cbox (- b) (- a)) (f \<circ> uminus)) < e"
      if "f \<in> F" and tag: "\<D> tagged_division_of cbox (- b) (- a)"
         and fine: "(\<lambda>x. uminus ` \<gamma> (- x)) fine \<D>" for f \<D>
    proof -
      have 1: "(\<lambda>(x,K). (- x, uminus ` K)) ` \<D> tagged_partial_division_of cbox a b"
        if "\<D> tagged_partial_division_of cbox (- b) (- a)"
      proof -
        have "- y \<in> cbox a b"
          if "\<And>x K. (x,K) \<in> \<D> \<Longrightarrow> x \<in> K \<and> K \<subseteq> cbox (- b) (- a) \<and> (\<exists>a b. K = cbox a b)"
             "(x, Y) \<in> \<D>" "y \<in> Y" for x Y y
        proof -
          have "y \<in> uminus ` cbox a b"
            using that by auto
          then show "- y \<in> cbox a b"
            by force
        qed
        with that show ?thesis
          by (fastforce simp: tagged_partial_division_of_def interior_negations image_iff)
      qed
      have 2: "\<exists>K. (\<exists>x. (x,K) \<in> (\<lambda>(x,K). (- x, uminus ` K)) ` \<D>) \<and> x \<in> K"
              if "\<Union>{K. \<exists>x. (x,K) \<in> \<D>} = cbox (- b) (- a)" "x \<in> cbox a b" for x
      proof -
        have xm: "x \<in> uminus ` \<Union>{A. \<exists>a. (a, A) \<in> \<D>}"
          by (simp add: that)
        then obtain a X where "-x \<in> X" "(a, X) \<in> \<D>"
          by auto
        then show ?thesis
          by (metis (no_types, lifting) add.inverse_inverse image_iff pair_imageI)
      qed
      have 3: "\<And>x X y. \<lbrakk>\<D> tagged_partial_division_of cbox (- b) (- a); (x, X) \<in> \<D>; y \<in> X\<rbrakk> \<Longrightarrow> - y \<in> cbox a b"
        by (metis (no_types, lifting) equation_minus_iff imageE subsetD tagged_partial_division_ofD(3) uminus_interval_vector)
      have tag': "(\<lambda>(x,K). (- x, uminus ` K)) ` \<D> tagged_division_of cbox a b"
        using tag  by (auto simp: tagged_division_of_def dest: 1 2 3)
      have fine': "\<gamma> fine (\<lambda>(x,K). (- x, uminus ` K)) ` \<D>"
        using fine by (fastforce simp: fine_def)
      have inj: "inj_on (\<lambda>(x,K). (- x, uminus ` K)) \<D>"
        unfolding inj_on_def by force
      have eq: "content (uminus ` I) = content I"
               if I: "(x, I) \<in> \<D>" and fnz: "f (- x) \<noteq> 0" for x I
      proof -
        obtain a b where "I = cbox a b"
          using tag I that by (force simp: tagged_division_of_def tagged_partial_division_of_def)
        then show ?thesis
          using content_image_affinity_cbox [of "-1" 0] by auto
      qed
      have "(\<Sum>(x,K) \<in> (\<lambda>(x,K). (- x, uminus ` K)) ` \<D>.  content K *\<^sub>R f x) =
            (\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f (- x))"
        apply (simp add: sum.reindex [OF inj])
        apply (auto simp: eq intro!: sum.cong)
        done
      then show ?thesis
        using \<gamma> [OF \<open>f \<in> F\<close> tag' fine'] integral_reflect
        by (metis (mono_tags, lifting) Henstock_Kurzweil_Integration.integral_cong comp_apply split_def sum.cong)
    qed
  qed
  then show ?thesis
    using assms
    apply (auto simp: equiintegrable_on_def)
    apply (rule integrable_eq)
    by auto 
qed

subsection%important\<open>Subinterval restrictions for equiintegrable families\<close>

text\<open>First, some technical lemmas about minimizing a "flat" part of a sum over a division.\<close>

lemma lemma0:
  assumes "i \<in> Basis"
    shows "content (cbox u v) / (interval_upperbound (cbox u v) \<bullet> i - interval_lowerbound (cbox u v) \<bullet> i) =
           (if content (cbox u v) = 0 then 0
            else \<Prod>j \<in> Basis - {i}. interval_upperbound (cbox u v) \<bullet> j - interval_lowerbound (cbox u v) \<bullet> j)"
proof (cases "content (cbox u v) = 0")
  case True
  then show ?thesis by simp
next
  case False
  then show ?thesis
    using prod.subset_diff [of "{i}" Basis] assms
      by (force simp: content_cbox_if divide_simps  split: if_split_asm)
qed


lemma%important content_division_lemma1:
  assumes div: "\<D> division_of S" and S: "S \<subseteq> cbox a b" and i: "i \<in> Basis"
      and mt: "\<And>K. K \<in> \<D> \<Longrightarrow> content K \<noteq> 0"
      and disj: "(\<forall>K \<in> \<D>. K \<inter> {x. x \<bullet> i = a \<bullet> i} \<noteq> {}) \<or> (\<forall>K \<in> \<D>. K \<inter> {x. x \<bullet> i = b \<bullet> i} \<noteq> {})"
   shows "(b \<bullet> i - a \<bullet> i) * (\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))
          \<le> content(cbox a b)"   (is "?lhs \<le> ?rhs")
proof%unimportant -
  have "finite \<D>"
    using div by blast
  define extend where
    "extend \<equiv> \<lambda>K. cbox (\<Sum>j \<in> Basis. if j = i then (a \<bullet> i) *\<^sub>R i else (interval_lowerbound K \<bullet> j) *\<^sub>R j)
                       (\<Sum>j \<in> Basis. if j = i then (b \<bullet> i) *\<^sub>R i else (interval_upperbound K \<bullet> j) *\<^sub>R j)"
  have div_subset_cbox: "\<And>K. K \<in> \<D> \<Longrightarrow> K \<subseteq> cbox a b"
    using S div by auto
  have "\<And>K. K \<in> \<D> \<Longrightarrow> K \<noteq> {}"
    using div by blast
  have extend: "extend K \<noteq> {}" "extend K \<subseteq> cbox a b" if K: "K \<in> \<D>" for K
  proof -
    obtain u v where K: "K = cbox u v" "K \<noteq> {}" "K \<subseteq> cbox a b"
      using K cbox_division_memE [OF _ div] by (meson div_subset_cbox)
    with i show "extend K \<noteq> {}" "extend K \<subseteq> cbox a b"
      apply (auto simp: extend_def subset_box box_ne_empty sum_if_inner)
      by fastforce
  qed
  have int_extend_disjoint:
       "interior(extend K1) \<inter> interior(extend K2) = {}" if K: "K1 \<in> \<D>" "K2 \<in> \<D>" "K1 \<noteq> K2" for K1 K2
  proof -
    obtain u v where K1: "K1 = cbox u v" "K1 \<noteq> {}" "K1 \<subseteq> cbox a b"
      using K cbox_division_memE [OF _ div] by (meson div_subset_cbox)
    obtain w z where K2: "K2 = cbox w z" "K2 \<noteq> {}" "K2 \<subseteq> cbox a b"
      using K cbox_division_memE [OF _ div] by (meson div_subset_cbox)
    have cboxes: "cbox u v \<in> \<D>" "cbox w z \<in> \<D>" "cbox u v \<noteq> cbox w z"
      using K1 K2 that by auto
    with div have "interior (cbox u v) \<inter> interior (cbox w z) = {}"
      by blast
    moreover
    have "\<exists>x. x \<in> box u v \<and> x \<in> box w z"
         if "x \<in> interior (extend K1)" "x \<in> interior (extend K2)" for x
    proof -
      have "a \<bullet> i < x \<bullet> i" "x \<bullet> i < b \<bullet> i"
       and ux: "\<And>k. k \<in> Basis - {i} \<Longrightarrow> u \<bullet> k < x \<bullet> k"
       and xv: "\<And>k. k \<in> Basis - {i} \<Longrightarrow> x \<bullet> k < v \<bullet> k"
       and wx: "\<And>k. k \<in> Basis - {i} \<Longrightarrow> w \<bullet> k < x \<bullet> k"
       and xz: "\<And>k. k \<in> Basis - {i} \<Longrightarrow> x \<bullet> k < z \<bullet> k"
        using that K1 K2 i by (auto simp: extend_def box_ne_empty sum_if_inner mem_box)
      have "box u v \<noteq> {}" "box w z \<noteq> {}"
        using cboxes interior_cbox by (auto simp: content_eq_0_interior dest: mt)
      then obtain q s
        where q: "\<And>k. k \<in> Basis \<Longrightarrow> w \<bullet> k < q \<bullet> k \<and> q \<bullet> k < z \<bullet> k"
          and s: "\<And>k. k \<in> Basis \<Longrightarrow> u \<bullet> k < s \<bullet> k \<and> s \<bullet> k < v \<bullet> k"
        by (meson all_not_in_conv mem_box(1))
      show ?thesis  using disj
      proof
        assume "\<forall>K\<in>\<D>. K \<inter> {x. x \<bullet> i = a \<bullet> i} \<noteq> {}"
        then have uva: "(cbox u v) \<inter> {x. x \<bullet> i = a \<bullet> i} \<noteq> {}"
             and  wza: "(cbox w z) \<inter> {x. x \<bullet> i = a \<bullet> i} \<noteq> {}"
          using cboxes by (auto simp: content_eq_0_interior)
        then obtain r t where "r \<bullet> i = a \<bullet> i" and r: "\<And>k. k \<in> Basis \<Longrightarrow> w \<bullet> k \<le> r \<bullet> k \<and> r \<bullet> k \<le> z \<bullet> k"
                        and "t \<bullet> i = a \<bullet> i" and t: "\<And>k. k \<in> Basis \<Longrightarrow> u \<bullet> k \<le> t \<bullet> k \<and> t \<bullet> k \<le> v \<bullet> k"
          by (fastforce simp: mem_box)
        have u: "u \<bullet> i < q \<bullet> i"
          using i K2(1) K2(3) \<open>t \<bullet> i = a \<bullet> i\<close> q s t [OF i] by (force simp: subset_box)
        have w: "w \<bullet> i < s \<bullet> i"
          using i K1(1) K1(3) \<open>r \<bullet> i = a \<bullet> i\<close> s r [OF i] by (force simp: subset_box)
        let ?x = "(\<Sum>j \<in> Basis. if j = i then min (q \<bullet> i) (s \<bullet> i) *\<^sub>R i else (x \<bullet> j) *\<^sub>R j)"
        show ?thesis
        proof (intro exI conjI)
          show "?x \<in> box u v"
            using \<open>i \<in> Basis\<close> s apply (clarsimp simp: mem_box)
            apply (subst sum_if_inner; simp)+
            apply (fastforce simp: u ux xv)
            done
          show "?x \<in> box w z"
            using \<open>i \<in> Basis\<close> q apply (clarsimp simp: mem_box)
            apply (subst sum_if_inner; simp)+
            apply (fastforce simp: w wx xz)
            done
        qed
      next
        assume "\<forall>K\<in>\<D>. K \<inter> {x. x \<bullet> i = b \<bullet> i} \<noteq> {}"
        then have uva: "(cbox u v) \<inter> {x. x \<bullet> i = b \<bullet> i} \<noteq> {}"
             and  wza: "(cbox w z) \<inter> {x. x \<bullet> i = b \<bullet> i} \<noteq> {}"
          using cboxes by (auto simp: content_eq_0_interior)
        then obtain r t where "r \<bullet> i = b \<bullet> i" and r: "\<And>k. k \<in> Basis \<Longrightarrow> w \<bullet> k \<le> r \<bullet> k \<and> r \<bullet> k \<le> z \<bullet> k"
                        and "t \<bullet> i = b \<bullet> i" and t: "\<And>k. k \<in> Basis \<Longrightarrow> u \<bullet> k \<le> t \<bullet> k \<and> t \<bullet> k \<le> v \<bullet> k"
          by (fastforce simp: mem_box)
        have z: "s \<bullet> i < z \<bullet> i"
          using K1(1) K1(3) \<open>r \<bullet> i = b \<bullet> i\<close> r [OF i] i s  by (force simp: subset_box)
        have v: "q \<bullet> i < v \<bullet> i"
          using K2(1) K2(3) \<open>t \<bullet> i = b \<bullet> i\<close> t [OF i] i q  by (force simp: subset_box)
        let ?x = "(\<Sum>j \<in> Basis. if j = i then max (q \<bullet> i) (s \<bullet> i) *\<^sub>R i else (x \<bullet> j) *\<^sub>R j)"
        show ?thesis
        proof (intro exI conjI)
          show "?x \<in> box u v"
            using \<open>i \<in> Basis\<close> s apply (clarsimp simp: mem_box)
            apply (subst sum_if_inner; simp)+
            apply (fastforce simp: v ux xv)
            done
          show "?x \<in> box w z"
            using \<open>i \<in> Basis\<close> q apply (clarsimp simp: mem_box)
            apply (subst sum_if_inner; simp)+
            apply (fastforce simp: z wx xz)
            done
        qed
      qed
    qed
    ultimately show ?thesis by auto
  qed
  have "?lhs = (\<Sum>K\<in>\<D>. (b \<bullet> i - a \<bullet> i) * content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))"
    by (simp add: sum_distrib_left)
  also have "\<dots> = sum (content \<circ> extend) \<D>"
  proof (rule sum.cong [OF refl])
    fix K assume "K \<in> \<D>"
    then obtain u v where K: "K = cbox u v" "cbox u v \<noteq> {}" "K \<subseteq> cbox a b"
      using cbox_division_memE [OF _ div] div_subset_cbox by metis
    then have uv: "u \<bullet> i < v \<bullet> i"
      using mt [OF \<open>K \<in> \<D>\<close>] \<open>i \<in> Basis\<close> content_eq_0 by fastforce
    have "insert i (Basis \<inter> -{i}) = Basis"
      using \<open>i \<in> Basis\<close> by auto
    then have "(b \<bullet> i - a \<bullet> i) * content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)
             = (b \<bullet> i - a \<bullet> i) * (\<Prod>i \<in> insert i (Basis \<inter> -{i}). v \<bullet> i - u \<bullet> i) / (interval_upperbound (cbox u v) \<bullet> i - interval_lowerbound (cbox u v) \<bullet> i)"
      using K box_ne_empty(1) content_cbox by fastforce
    also have "... = (\<Prod>x\<in>Basis. if x = i then b \<bullet> x - a \<bullet> x
                      else (interval_upperbound (cbox u v) - interval_lowerbound (cbox u v)) \<bullet> x)"
      using \<open>i \<in> Basis\<close> K uv by (simp add: prod.If_cases) (simp add: algebra_simps)
    also have "... = (\<Prod>k\<in>Basis.
                        (\<Sum>j\<in>Basis. if j = i then (b \<bullet> i - a \<bullet> i) *\<^sub>R i else ((interval_upperbound (cbox u v) - interval_lowerbound (cbox u v)) \<bullet> j) *\<^sub>R j) \<bullet> k)"
      using \<open>i \<in> Basis\<close> by (subst prod.cong [OF refl sum_if_inner]; simp)
    also have "... = (\<Prod>k\<in>Basis.
                        (\<Sum>j\<in>Basis. if j = i then (b \<bullet> i) *\<^sub>R i else (interval_upperbound (cbox u v) \<bullet> j) *\<^sub>R j) \<bullet> k -
                        (\<Sum>j\<in>Basis. if j = i then (a \<bullet> i) *\<^sub>R i else (interval_lowerbound (cbox u v) \<bullet> j) *\<^sub>R j) \<bullet> k)"
      apply (rule prod.cong [OF refl])
      using \<open>i \<in> Basis\<close>
      apply (subst sum_if_inner; simp add: algebra_simps)+
      done
    also have "... = (content \<circ> extend) K"
      using \<open>i \<in> Basis\<close> K box_ne_empty
      apply (simp add: extend_def)
      apply (subst content_cbox, auto)
      done
    finally show "(b \<bullet> i - a \<bullet> i) * content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)
         = (content \<circ> extend) K" .
  qed
  also have "... = sum content (extend ` \<D>)"
  proof -
    have "\<lbrakk>K1 \<in> \<D>; K2 \<in> \<D>; K1 \<noteq> K2; extend K1 = extend K2\<rbrakk> \<Longrightarrow> content (extend K1) = 0" for K1 K2
      using int_extend_disjoint [of K1 K2] extend_def by (simp add: content_eq_0_interior)
    then show ?thesis
      by (simp add: comm_monoid_add_class.sum.reindex_nontrivial [OF \<open>finite \<D>\<close>])
  qed
  also have "... \<le> ?rhs"
  proof (rule subadditive_content_division)
    show "extend ` \<D> division_of \<Union> (extend ` \<D>)"
      using int_extend_disjoint apply (auto simp: division_of_def \<open>finite \<D>\<close> extend)
      using extend_def apply blast
      done
    show "\<Union> (extend ` \<D>) \<subseteq> cbox a b"
      using extend by fastforce
  qed
  finally show ?thesis .
qed


proposition%important sum_content_area_over_thin_division:
  assumes div: "\<D> division_of S" and S: "S \<subseteq> cbox a b" and i: "i \<in> Basis"
    and "a \<bullet> i \<le> c" "c \<le> b \<bullet> i"
    and nonmt: "\<And>K. K \<in> \<D> \<Longrightarrow> K \<inter> {x. x \<bullet> i = c} \<noteq> {}"
  shows "(b \<bullet> i - a \<bullet> i) * (\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))
          \<le> 2 * content(cbox a b)"
proof%unimportant (cases "content(cbox a b) = 0")
  case True
  have "(\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) = 0"
    using S div by (force intro!: sum.neutral content_0_subset [OF True])
  then show ?thesis
    by (auto simp: True)
next
  case False
  then have "content(cbox a b) > 0"
    using zero_less_measure_iff by blast
  then have "a \<bullet> i < b \<bullet> i" if "i \<in> Basis" for i
    using content_pos_lt_eq that by blast
  have "finite \<D>"
    using div by blast
  define Dlec where "Dlec \<equiv> {L \<in> (\<lambda>L. L \<inter> {x. x \<bullet> i \<le> c}) ` \<D>. content L \<noteq> 0}"
  define Dgec where "Dgec \<equiv> {L \<in> (\<lambda>L. L \<inter> {x. x \<bullet> i \<ge> c}) ` \<D>. content L \<noteq> 0}"
  define a' where "a' \<equiv> (\<Sum>j\<in>Basis. (if j = i then c else a \<bullet> j) *\<^sub>R j)"
  define b' where "b' \<equiv> (\<Sum>j\<in>Basis. (if j = i then c else b \<bullet> j) *\<^sub>R j)"
  have Dlec_cbox: "\<And>K. K \<in> Dlec \<Longrightarrow> \<exists>a b. K = cbox a b"
    using interval_split [OF i] div by (fastforce simp: Dlec_def division_of_def)
  then have lec_is_cbox: "\<lbrakk>content (L \<inter> {x. x \<bullet> i \<le> c}) \<noteq> 0; L \<in> \<D>\<rbrakk> \<Longrightarrow> \<exists>a b. L \<inter> {x. x \<bullet> i \<le> c} = cbox a b" for L
    using Dlec_def by blast
  have Dgec_cbox: "\<And>K. K \<in> Dgec \<Longrightarrow> \<exists>a b. K = cbox a b"
    using interval_split [OF i] div by (fastforce simp: Dgec_def division_of_def)
  then have gec_is_cbox: "\<lbrakk>content (L \<inter> {x. x \<bullet> i \<ge> c}) \<noteq> 0; L \<in> \<D>\<rbrakk> \<Longrightarrow> \<exists>a b. L \<inter> {x. x \<bullet> i \<ge> c} = cbox a b" for L
    using Dgec_def by blast
  have "(b' \<bullet> i - a \<bullet> i) * (\<Sum>K\<in>Dlec. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<le> content(cbox a b')"
  proof (rule content_division_lemma1)
    show "Dlec division_of \<Union>Dlec"
      unfolding division_of_def
    proof (intro conjI ballI Dlec_cbox)
      show "\<And>K1 K2. \<lbrakk>K1 \<in> Dlec; K2 \<in> Dlec\<rbrakk> \<Longrightarrow> K1 \<noteq> K2 \<longrightarrow> interior K1 \<inter> interior K2 = {}"
        by (clarsimp simp: Dlec_def) (use div in auto)
    qed (use \<open>finite \<D>\<close> Dlec_def in auto)
    show "\<Union>Dlec \<subseteq> cbox a b'"
      using Dlec_def div S by (auto simp: b'_def division_of_def mem_box)
    show "(\<forall>K\<in>Dlec. K \<inter> {x. x \<bullet> i = a \<bullet> i} \<noteq> {}) \<or> (\<forall>K\<in>Dlec. K \<inter> {x. x \<bullet> i = b' \<bullet> i} \<noteq> {})"
      using nonmt by (fastforce simp: Dlec_def b'_def sum_if_inner i)
  qed (use i Dlec_def in auto)
  moreover
  have "(\<Sum>K\<in>Dlec. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) =
        (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<le> c}))) K)"
    apply (subst sum.reindex_nontrivial [OF \<open>finite \<D>\<close>, symmetric], simp)
     apply (metis division_split_left_inj [OF div] lec_is_cbox content_eq_0_interior)
    unfolding Dlec_def using \<open>finite \<D>\<close> apply (auto simp: sum.mono_neutral_left)
    done
  moreover have "(b' \<bullet> i - a \<bullet> i) = (c - a \<bullet> i)"
    by (simp add: b'_def sum_if_inner i)
  ultimately
  have lec: "(c - a \<bullet> i) * (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<le> c}))) K)
             \<le> content(cbox a b')"
    by simp

  have "(b \<bullet> i - a' \<bullet> i) * (\<Sum>K\<in>Dgec. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<le> content(cbox a' b)"
  proof (rule content_division_lemma1)
    show "Dgec division_of \<Union>Dgec"
      unfolding division_of_def
    proof (intro conjI ballI Dgec_cbox)
      show "\<And>K1 K2. \<lbrakk>K1 \<in> Dgec; K2 \<in> Dgec\<rbrakk> \<Longrightarrow> K1 \<noteq> K2 \<longrightarrow> interior K1 \<inter> interior K2 = {}"
        by (clarsimp simp: Dgec_def) (use div in auto)
    qed (use \<open>finite \<D>\<close> Dgec_def in auto)
    show "\<Union>Dgec \<subseteq> cbox a' b"
      using Dgec_def div S by (auto simp: a'_def division_of_def mem_box)
    show "(\<forall>K\<in>Dgec. K \<inter> {x. x \<bullet> i = a' \<bullet> i} \<noteq> {}) \<or> (\<forall>K\<in>Dgec. K \<inter> {x. x \<bullet> i = b \<bullet> i} \<noteq> {})"
      using nonmt by (fastforce simp: Dgec_def a'_def sum_if_inner i)
  qed (use i Dgec_def in auto)
  moreover
  have "(\<Sum>K\<in>Dgec. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) =
        (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<ge> c}))) K)"
    apply (subst sum.reindex_nontrivial [OF \<open>finite \<D>\<close>, symmetric], simp)
     apply (metis division_split_right_inj [OF div] gec_is_cbox content_eq_0_interior)
    unfolding Dgec_def using \<open>finite \<D>\<close> apply (auto simp: sum.mono_neutral_left)
    done
  moreover have "(b \<bullet> i - a' \<bullet> i) = (b \<bullet> i - c)"
    by (simp add: a'_def sum_if_inner i)
  ultimately
  have gec: "(b \<bullet> i - c) * (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<ge> c}))) K)
             \<le> content(cbox a' b)"
    by simp
  show ?thesis
  proof (cases "c = a \<bullet> i \<or> c = b \<bullet> i")
    case True
    then show ?thesis
    proof
      assume c: "c = a \<bullet> i"
      then have "a' = a"
        apply (simp add: sum_if_inner i a'_def cong: if_cong)
        using euclidean_representation [of a] sum.cong [OF refl, of Basis "\<lambda>i. (a \<bullet> i) *\<^sub>R i"] by presburger
      then have "content (cbox a' b) \<le> 2 * content (cbox a b)"  by simp
      moreover
      have eq: "(\<Sum>K\<in>\<D>. content (K \<inter> {x. a \<bullet> i \<le> x \<bullet> i}) /
                  (interval_upperbound (K \<inter> {x. a \<bullet> i \<le> x \<bullet> i}) \<bullet> i - interval_lowerbound (K \<inter> {x. a \<bullet> i \<le> x \<bullet> i}) \<bullet> i))
              = (\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))"
               (is "sum ?f _ = sum ?g _")
      proof (rule sum.cong [OF refl])
        fix K assume "K \<in> \<D>"
        then have "a \<bullet> i \<le> x \<bullet> i" if "x \<in> K" for x
          by (metis S UnionI div division_ofD(6) i mem_box(2) subsetCE that)
        then have "K \<inter> {x. a \<bullet> i \<le> x \<bullet> i} = K"
          by blast
        then show "?f K = ?g K"
          by simp
      qed
      ultimately show ?thesis
        using gec c eq by auto
    next
      assume c: "c = b \<bullet> i"
      then have "b' = b"
        apply (simp add: sum_if_inner i b'_def cong: if_cong)
        using euclidean_representation [of b] sum.cong [OF refl, of Basis "\<lambda>i. (b \<bullet> i) *\<^sub>R i"] by presburger
      then have "content (cbox a b') \<le> 2 * content (cbox a b)"  by simp
      moreover
      have eq: "(\<Sum>K\<in>\<D>. content (K \<inter> {x. x \<bullet> i \<le> b \<bullet> i}) /
                  (interval_upperbound (K \<inter> {x. x \<bullet> i \<le> b \<bullet> i}) \<bullet> i - interval_lowerbound (K \<inter> {x. x \<bullet> i \<le> b \<bullet> i}) \<bullet> i))
              = (\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))"
               (is "sum ?f _ = sum ?g _")
      proof (rule sum.cong [OF refl])
        fix K assume "K \<in> \<D>"
        then have "x \<bullet> i \<le> b \<bullet> i" if "x \<in> K" for x
          by (metis S UnionI div division_ofD(6) i mem_box(2) subsetCE that)
        then have "K \<inter> {x. x \<bullet> i \<le> b \<bullet> i} = K"
          by blast
        then show "?f K = ?g K"
          by simp
      qed
      ultimately show ?thesis
        using lec c eq by auto
    qed
  next
    case False
    have prod_if: "(\<Prod>k\<in>Basis \<inter> - {i}. f k) = (\<Prod>k\<in>Basis. f k) / f i" if "f i \<noteq> (0::real)" for f
      using that mk_disjoint_insert [OF i]
      apply (clarsimp simp add: divide_simps)
      by (metis Int_insert_left_if0 finite_Basis finite_insert le_iff_inf mult.commute order_refl prod.insert subset_Compl_singleton)
    have abc: "a \<bullet> i < c" "c < b \<bullet> i"
      using False assms by auto
    then have "(\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<le> c}))) K)
                  \<le> content(cbox a b') / (c - a \<bullet> i)"
              "(\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<ge> c}))) K)
                 \<le> content(cbox a' b) / (b \<bullet> i - c)"
      using lec gec by (simp_all add: divide_simps mult.commute)
    moreover
    have "(\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))
          \<le> (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<le> c}))) K) +
            (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<ge> c}))) K)"
           (is "?lhs \<le> ?rhs")
    proof -
      have "?lhs \<le>
            (\<Sum>K\<in>\<D>. ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<le> c}))) K +
                    ((\<lambda>K. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<circ> ((\<lambda>K. K \<inter> {x. x \<bullet> i \<ge> c}))) K)"
            (is "sum ?f _ \<le> sum ?g _")
      proof (rule sum_mono)
        fix K assume "K \<in> \<D>"
        then obtain u v where uv: "K = cbox u v"
          using div by blast
        obtain u' v' where uv': "cbox u v \<inter> {x. x \<bullet> i \<le> c} = cbox u v'"
                                "cbox u v \<inter> {x. c \<le> x \<bullet> i} = cbox u' v"
                                "\<And>k. k \<in> Basis \<Longrightarrow> u' \<bullet> k = (if k = i then max (u \<bullet> i) c else u \<bullet> k)"
                                "\<And>k. k \<in> Basis \<Longrightarrow> v' \<bullet> k = (if k = i then min (v \<bullet> i) c else v \<bullet> k)"
          using i by (auto simp: interval_split)
        have *: "\<lbrakk>content (cbox u v') = 0; content (cbox u' v) = 0\<rbrakk> \<Longrightarrow> content (cbox u v) = 0"
                "content (cbox u' v) \<noteq> 0 \<Longrightarrow> content (cbox u v) \<noteq> 0"
                "content (cbox u v') \<noteq> 0 \<Longrightarrow> content (cbox u v) \<noteq> 0"
          using i uv uv' by (auto simp: content_eq_0 le_max_iff_disj min_le_iff_disj split: if_split_asm intro: order_trans)
        show "?f K \<le> ?g K"
          using i uv uv' apply (clarsimp simp add: lemma0 * intro!: prod_nonneg)
          by (metis content_eq_0 le_less_linear order.strict_implies_order)
      qed
      also have "... = ?rhs"
        by (simp add: sum.distrib)
      finally show ?thesis .
    qed
    moreover have "content (cbox a b') / (c - a \<bullet> i) = content (cbox a b) / (b \<bullet> i - a \<bullet> i)"
      using i abc
      apply (simp add: field_simps a'_def b'_def measure_lborel_cbox_eq inner_diff)
      apply (auto simp: if_distrib if_distrib [of "\<lambda>f. f x" for x] prod.If_cases [of Basis "\<lambda>x. x = i", simplified] prod_if field_simps)
      done
    moreover have "content (cbox a' b) / (b \<bullet> i - c) = content (cbox a b) / (b \<bullet> i - a \<bullet> i)"
      using i abc
      apply (simp add: field_simps a'_def b'_def measure_lborel_cbox_eq inner_diff)
      apply (auto simp: if_distrib prod.If_cases [of Basis "\<lambda>x. x = i", simplified] prod_if field_simps)
      done
    ultimately
    have "(\<Sum>K\<in>\<D>. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))
          \<le> 2 * content (cbox a b) / (b \<bullet> i - a \<bullet> i)"
      by linarith
    then show ?thesis
      using abc by (simp add: divide_simps mult.commute)
  qed
qed




proposition%important bounded_equiintegral_over_thin_tagged_partial_division:
  fixes f :: "'a::euclidean_space \<Rightarrow> 'b::euclidean_space"
  assumes F: "F equiintegrable_on cbox a b" and f: "f \<in> F" and "0 < \<epsilon>"
      and norm_f: "\<And>h x. \<lbrakk>h \<in> F; x \<in> cbox a b\<rbrakk> \<Longrightarrow> norm(h x) \<le> norm(f x)"
  obtains \<gamma> where "gauge \<gamma>"
             "\<And>c i S h. \<lbrakk>c \<in> cbox a b; i \<in> Basis; S tagged_partial_division_of cbox a b;
                         \<gamma> fine S; h \<in> F; \<And>x K. (x,K) \<in> S \<Longrightarrow> (K \<inter> {x. x \<bullet> i = c \<bullet> i} \<noteq> {})\<rbrakk>
                        \<Longrightarrow> (\<Sum>(x,K) \<in> S. norm (integral K h)) < \<epsilon>"
proof%unimportant (cases "content(cbox a b) = 0")
  case True
  show ?thesis
  proof
    show "gauge (\<lambda>x. ball x 1)"
      by (simp add: gauge_trivial)
    show "(\<Sum>(x,K) \<in> S. norm (integral K h)) < \<epsilon>"
         if "S tagged_partial_division_of cbox a b" "(\<lambda>x. ball x 1) fine S" for S and h:: "'a \<Rightarrow> 'b"
    proof -
      have "(\<Sum>(x,K) \<in> S. norm (integral K h)) = 0"
          using that True content_0_subset
          by (fastforce simp: tagged_partial_division_of_def intro: sum.neutral)
      with \<open>0 < \<epsilon>\<close> show ?thesis
        by simp
    qed
  qed
next
  case False
  then have contab_gt0:  "content(cbox a b) > 0"
    by (simp add: zero_less_measure_iff)
  then have a_less_b: "\<And>i. i \<in> Basis \<Longrightarrow> a\<bullet>i < b\<bullet>i"
    by (auto simp: content_pos_lt_eq)
  obtain \<gamma>0 where "gauge \<gamma>0"
            and \<gamma>0: "\<And>S h. \<lbrakk>S tagged_partial_division_of cbox a b; \<gamma>0 fine S; h \<in> F\<rbrakk>
                           \<Longrightarrow> (\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x - integral K h)) < \<epsilon>/2"
  proof -
    obtain \<gamma> where "gauge \<gamma>"
               and \<gamma>: "\<And>f \<D>. \<lbrakk>f \<in> F; \<D> tagged_division_of cbox a b; \<gamma> fine \<D>\<rbrakk>
                              \<Longrightarrow> norm ((\<Sum>(x,K) \<in> \<D>. content K *\<^sub>R f x) - integral (cbox a b) f)
                                  < \<epsilon>/(5 * (Suc DIM('b)))"
    proof -
      have e5: "\<epsilon>/(5 * (Suc DIM('b))) > 0"
        using \<open>\<epsilon> > 0\<close> by auto
      then show ?thesis
        using F that by (auto simp: equiintegrable_on_def)
    qed
    show ?thesis
    proof
      show "gauge \<gamma>"
        by (rule \<open>gauge \<gamma>\<close>)
      show "(\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x - integral K h)) < \<epsilon>/2"
           if "S tagged_partial_division_of cbox a b" "\<gamma> fine S" "h \<in> F" for S h
      proof -
        have "(\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x - integral K h)) \<le> 2 * real DIM('b) * (\<epsilon>/(5 * Suc DIM('b)))"
        proof (rule Henstock_lemma_part2 [of h a b])
          show "h integrable_on cbox a b"
            using that F equiintegrable_on_def by metis
          show "gauge \<gamma>"
            by (rule \<open>gauge \<gamma>\<close>)
        qed (use that \<open>\<epsilon> > 0\<close> \<gamma> in auto)
        also have "... < \<epsilon>/2"
          using \<open>\<epsilon> > 0\<close> by (simp add: divide_simps)
        finally show ?thesis .
      qed
    qed
  qed
  define \<gamma> where "\<gamma> \<equiv> \<lambda>x. \<gamma>0 x \<inter>
                          ball x ((\<epsilon>/8 / (norm(f x) + 1)) * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / content(cbox a b))"
  have "gauge (\<lambda>x. ball x
                    (\<epsilon> * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / ((8 * norm (f x) + 8) * content (cbox a b))))"
    using \<open>0 < content (cbox a b)\<close> \<open>0 < \<epsilon>\<close> a_less_b
    apply (auto simp: gauge_def divide_simps mult_less_0_iff zero_less_mult_iff add_nonneg_eq_0_iff finite_less_Inf_iff)
    apply (meson add_nonneg_nonneg mult_nonneg_nonneg norm_ge_zero not_less zero_le_numeral)
    done
  then have "gauge \<gamma>"
    unfolding \<gamma>_def using \<open>gauge \<gamma>0\<close> gauge_Int by auto
  moreover
  have "(\<Sum>(x,K) \<in> S. norm (integral K h)) < \<epsilon>"
       if "c \<in> cbox a b" "i \<in> Basis" and S: "S tagged_partial_division_of cbox a b"
          and "\<gamma> fine S" "h \<in> F" and ne: "\<And>x K. (x,K) \<in> S \<Longrightarrow> K \<inter> {x. x \<bullet> i = c \<bullet> i} \<noteq> {}" for c i S h
  proof -
    have "cbox c b \<subseteq> cbox a b"
      by (meson mem_box(2) order_refl subset_box(1) that(1))
    have "finite S"
      using S by blast
    have "\<gamma>0 fine S" and fineS:
         "(\<lambda>x. ball x (\<epsilon> * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / ((8 * norm (f x) + 8) * content (cbox a b)))) fine S"
      using \<open>\<gamma> fine S\<close> by (auto simp: \<gamma>_def fine_Int)
    then have "(\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x - integral K h)) < \<epsilon>/2"
      by (intro \<gamma>0 that fineS)
    moreover have "(\<Sum>(x,K) \<in> S. norm (integral K h) - norm (content K *\<^sub>R h x - integral K h)) \<le> \<epsilon>/2"
    proof -
      have "(\<Sum>(x,K) \<in> S. norm (integral K h) - norm (content K *\<^sub>R h x - integral K h))
            \<le> (\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x))"
      proof (clarify intro!: sum_mono)
        fix x K
        assume xK: "(x,K) \<in> S"
        have "norm (integral K h) - norm (content K *\<^sub>R h x - integral K h) \<le> norm (integral K h - (integral K h - content K *\<^sub>R h x))"
          by (metis norm_minus_commute norm_triangle_ineq2)
        also have "... \<le> norm (content K *\<^sub>R h x)"
          by simp
        finally show "norm (integral K h) - norm (content K *\<^sub>R h x - integral K h) \<le> norm (content K *\<^sub>R h x)" .
      qed
      also have "... \<le> (\<Sum>(x,K) \<in> S. \<epsilon>/4 * (b \<bullet> i - a \<bullet> i) / content (cbox a b) *
                                    content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))"
      proof (clarify intro!: sum_mono)
        fix x K
        assume xK: "(x,K) \<in> S"
        then have x: "x \<in> cbox a b"
          using S unfolding tagged_partial_division_of_def by (meson subset_iff)
        let ?\<Delta> = "interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i"
        show "norm (content K *\<^sub>R h x) \<le> \<epsilon>/4 * (b \<bullet> i - a \<bullet> i) / content (cbox a b) * content K / ?\<Delta>"
        proof (cases "content K = 0")
          case True
          then show ?thesis by simp
        next
          case False
          then have Kgt0: "content K > 0"
            using zero_less_measure_iff by blast
          moreover
          obtain u v where uv: "K = cbox u v"
            using S \<open>(x,K) \<in> S\<close> by blast
          then have u_less_v: "\<And>i. i \<in> Basis \<Longrightarrow> u \<bullet> i < v \<bullet> i"
            using content_pos_lt_eq uv Kgt0 by blast
          then have dist_uv: "dist u v > 0"
            using that by auto
          ultimately have "norm (h x) \<le> (\<epsilon> * (b \<bullet> i - a \<bullet> i)) / (4 * content (cbox a b) * ?\<Delta>)"
          proof -
            have "dist x u < \<epsilon> * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2"
                 "dist x v < \<epsilon> * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2"
              using fineS u_less_v uv xK
              by (force simp: fine_def mem_box field_simps dest!: bspec)+
            moreover have "\<epsilon> * (INF m\<in>Basis. b \<bullet> m - a \<bullet> m) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2
                  \<le> \<epsilon> * (b \<bullet> i - a \<bullet> i) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2"
              apply (intro mult_left_mono divide_right_mono)
              using \<open>i \<in> Basis\<close> \<open>0 < \<epsilon>\<close> apply (auto simp: intro!: cInf_le_finite)
              done
            ultimately
            have "dist x u < \<epsilon> * (b \<bullet> i - a \<bullet> i) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2"
                 "dist x v < \<epsilon> * (b \<bullet> i - a \<bullet> i) / (4 * (norm (f x) + 1) * content (cbox a b)) / 2"
              by linarith+
            then have duv: "dist u v < \<epsilon> * (b \<bullet> i - a \<bullet> i) / (4 * (norm (f x) + 1) * content (cbox a b))"
              using dist_triangle_half_r by blast
            have uvi: "\<bar>v \<bullet> i - u \<bullet> i\<bar> \<le> norm (v - u)"
              by (metis inner_commute inner_diff_right \<open>i \<in> Basis\<close> Basis_le_norm)
            have "norm (h x) \<le> norm (f x)"
              using x that by (auto simp: norm_f)
            also have "... < (norm (f x) + 1)"
              by simp
            also have "... < \<epsilon> * (b \<bullet> i - a \<bullet> i) / dist u v / (4 * content (cbox a b))"
              using duv dist_uv contab_gt0
              apply (simp add: divide_simps algebra_simps mult_less_0_iff zero_less_mult_iff split: if_split_asm)
              by (meson add_nonneg_nonneg linorder_not_le measure_nonneg mult_nonneg_nonneg norm_ge_zero zero_le_numeral)
            also have "... = \<epsilon> * (b \<bullet> i - a \<bullet> i) / norm (v - u) / (4 * content (cbox a b))"
              by (simp add: dist_norm norm_minus_commute)
            also have "... \<le> \<epsilon> * (b \<bullet> i - a \<bullet> i) / \<bar>v \<bullet> i - u \<bullet> i\<bar> / (4 * content (cbox a b))"
              apply (intro mult_right_mono divide_left_mono divide_right_mono uvi)
              using \<open>0 < \<epsilon>\<close> a_less_b [OF \<open>i \<in> Basis\<close>] u_less_v [OF \<open>i \<in> Basis\<close>] contab_gt0
              by (auto simp: less_eq_real_def zero_less_mult_iff that)
            also have "... = \<epsilon> * (b \<bullet> i - a \<bullet> i)
                       / (4 * content (cbox a b) * ?\<Delta>)"
              using uv False that(2) u_less_v by fastforce
            finally show ?thesis by simp
          qed
          with Kgt0 have "norm (content K *\<^sub>R h x) \<le> content K * ((\<epsilon>/4 * (b \<bullet> i - a \<bullet> i) / content (cbox a b)) / ?\<Delta>)"
            using mult_left_mono by fastforce
          also have "... = \<epsilon>/4 * (b \<bullet> i - a \<bullet> i) / content (cbox a b) *
                           content K / ?\<Delta>"
            by (simp add: divide_simps)
          finally show ?thesis .
        qed
      qed
      also have "... = (\<Sum>K\<in>snd ` S. \<epsilon>/4 * (b \<bullet> i - a \<bullet> i) / content (cbox a b) * content K
                                     / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))"
        apply (rule sum.over_tagged_division_lemma [OF tagged_partial_division_of_Union_self [OF S]])
        apply (simp add: box_eq_empty(1) content_eq_0)
        done
      also have "... = \<epsilon>/2 * ((b \<bullet> i - a \<bullet> i) / (2 * content (cbox a b)) * (\<Sum>K\<in>snd ` S. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)))"
        by (simp add: sum_distrib_left mult.assoc)
      also have "... \<le> (\<epsilon>/2) * 1"
      proof (rule mult_left_mono)
        have "(b \<bullet> i - a \<bullet> i) * (\<Sum>K\<in>snd ` S. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i))
              \<le> 2 * content (cbox a b)"
        proof (rule sum_content_area_over_thin_division)
          show "snd ` S division_of \<Union>(snd ` S)"
            by (auto intro: S tagged_partial_division_of_Union_self division_of_tagged_division)
          show "\<Union>(snd ` S) \<subseteq> cbox a b"
            using S by force
          show "a \<bullet> i \<le> c \<bullet> i" "c \<bullet> i \<le> b \<bullet> i"
            using mem_box(2) that by blast+
        qed (use that in auto)
        then show "(b \<bullet> i - a \<bullet> i) / (2 * content (cbox a b)) * (\<Sum>K\<in>snd ` S. content K / (interval_upperbound K \<bullet> i - interval_lowerbound K \<bullet> i)) \<le> 1"
          by (simp add: contab_gt0)
      qed (use \<open>0 < \<epsilon>\<close> in auto)
      finally show ?thesis by simp
    qed
    then have "(\<Sum>(x,K) \<in> S. norm (integral K h)) - (\<Sum>(x,K) \<in> S. norm (content K *\<^sub>R h x - integral K h)) \<le> \<epsilon>/2"
      by (simp add: Groups_Big.sum_subtractf [symmetric])
    ultimately show "(\<Sum>(x,K) \<in> S. norm (integral K h)) < \<epsilon>"
      by linarith
  qed
  ultimately show ?thesis using that by auto
qed



proposition%important equiintegrable_halfspace_restrictions_le:
  fixes f :: "'a::euclidean_space \<Rightarrow> 'b::euclidean_space"
  assumes F: "F equiintegrable_on cbox a b" and f: "f \<in> F"
    and norm_f: "\<And>h x. \<lbrakk>h \<in> F; x \<in> cbox a b\<rbrakk> \<Longrightarrow> norm(h x) \<le> norm(f x)"
  shows "(\<Union>i \<in> Basis. \<Union>c. \<Union>h \<in> F. {(\<lambda>x. if x \<bullet> i \<le> c then h x else 0)})
         equiintegrable_on cbox a b"
proof%unimportant (cases "content(cbox a b) = 0")
  case True
  then show ?thesis by simp
next
  case False
  then have "content(cbox a b) > 0"
    using zero_less_measure_iff by blast
  then have "a \<bullet> i < b \<bullet> i" if "i \<in> Basis" for i
    using content_pos_lt_eq that by blast
  have int_F: "f integrable_on cbox a b" if "f \<in> F" for f
    using F that by (simp add: equiintegrable_on_def)
  let ?CI = "\<lambda>K h x. content K *\<^sub>R h x - integral K h"
  show ?thesis
    unfolding equiintegrable_on_def
  proof (intro conjI; clarify)
    show int_lec: "\<lbrakk>i \<in> Basis; h \<in> F\<rbrakk> \<Longrightarrow> (\<lambda>x. if x \<bullet> i \<le> c then h x else 0) integrable_on cbox a b" for i c h
      using integrable_restrict_Int [of "{x. x \<bullet> i \<le> c}" h]
      apply (auto simp: interval_split Int_commute mem_box intro!: integrable_on_subcbox int_F)
      by (metis (full_types, hide_lams) min.bounded_iff)
    show "\<exists>\<gamma>. gauge \<gamma> \<and>
              (\<forall>f T. f \<in> (\<Union>i\<in>Basis. \<Union>c. \<Union>h\<in>F. {\<lambda>x. if x \<bullet> i \<le> c then h x else 0}) \<and>
                     T tagged_division_of cbox a b \<and> \<gamma> fine T \<longrightarrow>
                     norm ((\<Sum>(x,K) \<in> T. content K *\<^sub>R f x) - integral (cbox a b) f) < \<epsilon>)"
      if "\<epsilon> > 0" for \<epsilon>
    proof -
      obtain \<gamma>0 where "gauge \<gamma>0" and \<gamma>0:
        "\<And>c i S h. \<lbrakk>c \<in> cbox a b; i \<in> Basis; S tagged_partial_division_of cbox a b;
                        \<gamma>0 fine S; h \<in> F; \<And>x K. (x,K) \<in> S \<Longrightarrow> (K \<inter> {x. x \<bullet> i = c \<bullet> i} \<noteq> {})\<rbrakk>
                       \<Longrightarrow> (\<Sum>(x,K) \<in> S. norm (integral K h)) < \<epsilon>/12"
        apply (rule bounded_equiintegral_over_thin_tagged_partial_division [OF F f, of \<open>\<epsilon>/12\<close>])
        using \<open>\<epsilon> > 0\<close> by (auto simp: norm_f)
      obtain \<gamma>1 where "gauge \<gamma>1"
        and \<gamma>1: "\<And>h T. \<lbrakk>h \<in> F; T tagged_division_of cbox a b; \<gamma>1 fine T\<rbrakk>
                              \<Longrightarrow> norm ((\<Sum>(x,K) \<in> T. content K *\<^sub>R h x) - integral (cbox a b) h)
                                  < \<epsilon>/(7 * (Suc DIM('b)))"
      proof -
        have e5: "\<epsilon>/(7 * (Suc DIM('b))) > 0"
          using \<open>\<epsilon> > 0\<close> by auto
        then show ?thesis
          using F that by (auto simp: equiintegrable_on_def)
      qed
      have h_less3: "(\<Sum>(x,K) \<in> T. norm (?CI K h x)) < \<epsilon>/3"
        if "T tagged_partial_division_of cbox a b" "\<gamma>1 fine T" "h \<in> F" for T h
      proof -
        have "(\<Sum>(x,K) \<in> T. norm (?CI K h x)) \<le> 2 * real DIM('b) * (\<epsilon>/(7 * Suc DIM('b)))"
        proof (rule Henstock_lemma_part2 [of h a b])
          show "h integrable_on cbox a b"
            using that F equiintegrable_on_def by metis
          show "gauge \<gamma>1"
            by (rule \<open>gauge \<gamma>1\<close>)
        qed (use that \<open>\<epsilon> > 0\<close> \<gamma>1 in auto)
        also have "... < \<epsilon>/3"
          using \<open>\<epsilon> > 0\<close> by (simp add: divide_simps)
        finally show ?thesis .
      qed
      have *: "norm ((\<Sum>(x,K) \<in> T. content K *\<^sub>R f x) - integral (cbox a b) f) < \<epsilon>"
                if f: "f = (\<lambda>x. if x \<bullet> i \<le> c then h x else 0)"
                and T: "T tagged_division_of cbox a b"
                and fine: "(\<lambda>x. \<gamma>0 x \<inter> \<gamma>1 x) fine T" and "i \<in> Basis" "h \<in> F" for f T i c h
      proof (cases "a \<bullet> i \<le> c \<and> c \<le> b \<bullet> i")
        case True
        have "finite T"
          using T by blast
        define T' where "T' \<equiv> {(x,K) \<in> T. K \<inter> {x. x \<bullet> i \<le> c} \<noteq> {}}"
        then have "T' \<subseteq> T"
          by auto
        then have "finite T'"
          using \<open>finite T\<close> infinite_super by blast
        have T'_tagged: "T' tagged_partial_division_of cbox a b"
          by (meson T \<open>T' \<subseteq> T\<close> tagged_division_of_def tagged_partial_division_subset)
        have fine': "\<gamma>0 fine T'" "\<gamma>1 fine T'"
          using \<open>T' \<subseteq> T\<close> fine_Int fine_subset fine by blast+
        have int_KK': "(\<Sum>(x,K) \<in> T. integral K f) = (\<Sum>(x,K) \<in> T'. integral K f)"
          apply (rule sum.mono_neutral_right [OF \<open>finite T\<close> \<open>T' \<subseteq> T\<close>])
          using f \<open>finite T\<close> \<open>T' \<subseteq> T\<close>
          using integral_restrict_Int [of _ "{x. x \<bullet> i \<le> c}" h]
          apply (auto simp: T'_def Int_commute)
          done
        have "(\<Sum>(x,K) \<in> T. content K *\<^sub>R f x) = (\<Sum>(x,K) \<in> T'. content K *\<^sub>R f x)"
          apply (rule sum.mono_neutral_right [OF \<open>finite T\<close> \<open>T' \<subseteq> T\<close>])
          using T f \<open>finite T\<close> \<open>T' \<subseteq> T\<close> apply (force simp: T'_def)
          done
        moreover have "norm ((\<Sum>(x,K) \<in> T'. content K *\<^sub>R f x) - integral (cbox a b) f) < \<epsilon>"
        proof -
          have *: "norm y < \<epsilon>" if "norm x < \<epsilon>/3" "norm(x - y) \<le> 2 * \<epsilon>/3" for x y::'b
          proof -
            have "norm y \<le> norm x + norm(x - y)"
              by (metis norm_minus_commute norm_triangle_sub)
            also have "\<dots> < \<epsilon>/3 + 2*\<epsilon>/3"
              using that by linarith
            also have "... = \<epsilon>"
              by simp
            finally show ?thesis .
          qed
          have "norm (\<Sum>(x,K) \<in> T'. ?CI K h x)
                \<le> (\<Sum>(x,K) \<in> T'. norm (?CI K h x))"
            by (simp add: norm_sum split_def)
          also have "... < \<epsilon>/3"
            by (intro h_less3 T'_tagged fine' that)
          finally have "norm (\<Sum>(x,K) \<in> T'. ?CI K h x) < \<epsilon>/3" .
          moreover have "integral (cbox a b) f = (\<Sum>(x,K) \<in> T. integral K f)"
            using int_lec that by (auto simp: integral_combine_tagged_division_topdown)
          moreover have "norm (\<Sum>(x,K) \<in> T'. ?CI K h x - ?CI K f x)
                \<le> 2*\<epsilon>/3"
          proof -
            define T'' where "T'' \<equiv> {(x,K) \<in> T'. ~ (K \<subseteq> {x. x \<bullet> i \<le> c})}"
            then have "T'' \<subseteq> T'"
              by auto
            then have "finite T''"
              using \<open>finite T'\<close> infinite_super by blast
            have T''_tagged: "T'' tagged_partial_division_of cbox a b"
              using T'_tagged \<open>T'' \<subseteq> T'\<close> tagged_partial_division_subset by blast
            have fine'': "\<gamma>0 fine T''" "\<gamma>1 fine T''"
              using \<open>T'' \<subseteq> T'\<close> fine' by (blast intro: fine_subset)+
            have "(\<Sum>(x,K) \<in> T'. ?CI K h x - ?CI K f x)
                = (\<Sum>(x,K) \<in> T''. ?CI K h x - ?CI K f x)"
            proof (clarify intro!: sum.mono_neutral_right [OF \<open>finite T'\<close> \<open>T'' \<subseteq> T'\<close>])
              fix x K
              assume "(x,K) \<in> T'" "(x,K) \<notin> T''"
              then have "x \<in> K" "x \<bullet> i \<le> c" "{x. x \<bullet> i \<le> c} \<inter> K = K"
                using T''_def T'_tagged by blast+
              then show "?CI K h x - ?CI K f x = 0"
                using integral_restrict_Int [of _ "{x. x \<bullet> i \<le> c}" h] by (auto simp: f)
            qed
            moreover have "norm (\<Sum>(x,K) \<in> T''. ?CI K h x - ?CI K f x) \<le> 2*\<epsilon>/3"
            proof -
              define A where "A \<equiv> {(x,K) \<in> T''. x \<bullet> i \<le> c}"
              define B where "B \<equiv> {(x,K) \<in> T''. x \<bullet> i > c}"
              then have "A \<subseteq> T''" "B \<subseteq> T''" and disj: "A \<inter> B = {}" and T''_eq: "T'' = A \<union> B"
                by (auto simp: A_def B_def)
              then have "finite A" "finite B"
                using \<open>finite T''\<close>  by (auto intro: finite_subset)
              have A_tagged: "A tagged_partial_division_of cbox a b"
                using T''_tagged \<open>A \<subseteq> T''\<close> tagged_partial_division_subset by blast
              have fineA: "\<gamma>0 fine A" "\<gamma>1 fine A"
                using \<open>A \<subseteq> T''\<close> fine'' by (blast intro: fine_subset)+
              have B_tagged: "B tagged_partial_division_of cbox a b"
                using T''_tagged \<open>B \<subseteq> T''\<close> tagged_partial_division_subset by blast
              have fineB: "\<gamma>0 fine B" "\<gamma>1 fine B"
                using \<open>B \<subseteq> T''\<close> fine'' by (blast intro: fine_subset)+
              have "norm (\<Sum>(x,K) \<in> T''. ?CI K h x - ?CI K f x)
                          \<le> (\<Sum>(x,K) \<in> T''. norm (?CI K h x - ?CI K f x))"
                by (simp add: norm_sum split_def)
              also have "... = (\<Sum>(x,K) \<in> A. norm (?CI K h x - ?CI K f x)) +
                               (\<Sum>(x,K) \<in> B. norm (?CI K h x - ?CI K f x))"
                by (simp add: sum.union_disjoint T''_eq disj \<open>finite A\<close> \<open>finite B\<close>)
              also have "... = (\<Sum>(x,K) \<in> A. norm (integral K h - integral K f)) +
                               (\<Sum>(x,K) \<in> B. norm (?CI K h x + integral K f))"
                by (auto simp: A_def B_def f norm_minus_commute intro!: sum.cong arg_cong2 [where f= "(+)"])
              also have "... \<le> (\<Sum>(x,K)\<in>A. norm (integral K h)) +
                                 (\<Sum>(x,K)\<in>(\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c})) ` A. norm (integral K h))
                             + ((\<Sum>(x,K)\<in>B. norm (?CI K h x)) +
                                (\<Sum>(x,K)\<in>B. norm (integral K h)) +
                                  (\<Sum>(x,K)\<in>(\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B. norm (integral K h)))"
              proof (rule add_mono)
                show "(\<Sum>(x,K)\<in>A. norm (integral K h - integral K f))
                        \<le> (\<Sum>(x,K)\<in>A. norm (integral K h)) +
                           (\<Sum>(x,K)\<in>(\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c})) ` A.
                              norm (integral K h))"
                proof (subst sum.reindex_nontrivial [OF \<open>finite A\<close>], clarsimp)
                  fix x K L
                  assume "(x,K) \<in> A" "(x,L) \<in> A"
                    and int_ne0: "integral (L \<inter> {x. x \<bullet> i \<le> c}) h \<noteq> 0"
                    and eq: "K \<inter> {x. x \<bullet> i \<le> c} = L \<inter> {x. x \<bullet> i \<le> c}"
                  have False if "K \<noteq> L"
                  proof -
                    obtain u v where uv: "L = cbox u v"
                      using T'_tagged \<open>(x, L) \<in> A\<close> \<open>A \<subseteq> T''\<close> \<open>T'' \<subseteq> T'\<close> by blast
                    have "A tagged_division_of \<Union>(snd ` A)"
                      using A_tagged tagged_partial_division_of_Union_self by auto
                    then have "interior (K \<inter> {x. x \<bullet> i \<le> c}) = {}"
                      apply (rule tagged_division_split_left_inj [OF _ \<open>(x,K) \<in> A\<close> \<open>(x,L) \<in> A\<close>])
                      using that eq \<open>i \<in> Basis\<close> by auto
                    then show False
                      using interval_split [OF \<open>i \<in> Basis\<close>] int_ne0 content_eq_0_interior eq uv by fastforce
                  qed
                  then show "K = L" by blast
                next
                  show "(\<Sum>(x,K) \<in> A. norm (integral K h - integral K f))
                          \<le> (\<Sum>(x,K) \<in> A. norm (integral K h)) +
                             sum ((\<lambda>(x,K). norm (integral K h)) \<circ> (\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c}))) A"
                    using integral_restrict_Int [of _ "{x. x \<bullet> i \<le> c}" h] f
                    by (auto simp: Int_commute A_def [symmetric] sum.distrib [symmetric] intro!: sum_mono norm_triangle_ineq4)
                qed
              next
                show "(\<Sum>(x,K)\<in>B. norm (?CI K h x + integral K f))
                      \<le> (\<Sum>(x,K)\<in>B. norm (?CI K h x)) + (\<Sum>(x,K)\<in>B. norm (integral K h)) +
                         (\<Sum>(x,K)\<in>(\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B. norm (integral K h))"
                proof (subst sum.reindex_nontrivial [OF \<open>finite B\<close>], clarsimp)
                  fix x K L
                  assume "(x,K) \<in> B" "(x,L) \<in> B"
                    and int_ne0: "integral (L \<inter> {x. c \<le> x \<bullet> i}) h \<noteq> 0"
                    and eq: "K \<inter> {x. c \<le> x \<bullet> i} = L \<inter> {x. c \<le> x \<bullet> i}"
                  have False if "K \<noteq> L"
                  proof -
                    obtain u v where uv: "L = cbox u v"
                      using T'_tagged \<open>(x, L) \<in> B\<close> \<open>B \<subseteq> T''\<close> \<open>T'' \<subseteq> T'\<close> by blast
                    have "B tagged_division_of \<Union>(snd ` B)"
                      using B_tagged tagged_partial_division_of_Union_self by auto
                    then have "interior (K \<inter> {x. c \<le> x \<bullet> i}) = {}"
                      apply (rule tagged_division_split_right_inj [OF _ \<open>(x,K) \<in> B\<close> \<open>(x,L) \<in> B\<close>])
                      using that eq \<open>i \<in> Basis\<close> by auto
                    then show False
                      using interval_split [OF \<open>i \<in> Basis\<close>] int_ne0
                        content_eq_0_interior eq uv by fastforce
                  qed
                  then show "K = L" by blast
                next
                  show "(\<Sum>(x,K) \<in> B. norm (?CI K h x + integral K f))
                        \<le> (\<Sum>(x,K) \<in> B. norm (?CI K h x)) +
                           (\<Sum>(x,K) \<in> B. norm (integral K h)) + sum ((\<lambda>(x,K). norm (integral K h)) \<circ> (\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i}))) B"
                  proof (clarsimp simp: B_def [symmetric] sum.distrib [symmetric] intro!: sum_mono)
                    fix x K
                    assume "(x,K) \<in> B"
                    have *: "i = i1 + i2 \<Longrightarrow> norm(c + i1) \<le> norm c + norm i + norm(i2)"
                      for i::'b and c i1 i2
                      by (metis add.commute add.left_commute add_diff_cancel_right' dual_order.refl norm_add_rule_thm norm_triangle_ineq4)
                    obtain u v where uv: "K = cbox u v"
                      using T'_tagged \<open>(x,K) \<in> B\<close> \<open>B \<subseteq> T''\<close> \<open>T'' \<subseteq> T'\<close> by blast
                    have "h integrable_on cbox a b"
                      by (simp add: int_F \<open>h \<in> F\<close>)
                    then have huv: "h integrable_on cbox u v"
                      apply (rule integrable_on_subcbox)
                      using B_tagged \<open>(x,K) \<in> B\<close> uv by blast
                    have "integral K h = integral K f + integral (K \<inter> {x. c \<le> x \<bullet> i}) h"
                      using integral_restrict_Int [of _ "{x. x \<bullet> i \<le> c}" h] f uv \<open>i \<in> Basis\<close>
                      by (simp add: Int_commute integral_split [OF huv \<open>i \<in> Basis\<close>])
                  then show "norm (?CI K h x + integral K f)
                             \<le> norm (?CI K h x) + norm (integral K h) + norm (integral (K \<inter> {x. c \<le> x \<bullet> i}) h)"
                    by (rule *)
                qed
              qed
            qed
            also have "... \<le> 2*\<epsilon>/3"
            proof -
              have overlap: "K \<inter> {x. x \<bullet> i = c} \<noteq> {}" if "(x,K) \<in> T''" for x K
              proof -
                obtain y y' where y: "y' \<in> K" "c < y' \<bullet> i" "y \<in> K" "y \<bullet> i \<le> c"
                  using that  T''_def T'_def \<open>(x,K) \<in> T''\<close> by fastforce
                obtain u v where uv: "K = cbox u v"
                  using T''_tagged \<open>(x,K) \<in> T''\<close> by blast
                then have "connected K"
                  by (simp add: is_interval_cbox is_interval_connected)
                then have "(\<exists>z \<in> K. z \<bullet> i = c)"
                  using y connected_ivt_component by fastforce
                then show ?thesis
                  by fastforce
              qed
              have **: "\<lbrakk>x < \<epsilon>/12; y < \<epsilon>/12; z \<le> \<epsilon>/2\<rbrakk> \<Longrightarrow> x + y + z \<le> 2 * \<epsilon>/3" for x y z
                by auto
              show ?thesis
              proof (rule **)
                have cb_ab: "(\<Sum>j \<in> Basis. if j = i then c *\<^sub>R i else (a \<bullet> j) *\<^sub>R j) \<in> cbox a b"
                  using \<open>i \<in> Basis\<close> True \<open>\<And>i. i \<in> Basis \<Longrightarrow> a \<bullet> i < b \<bullet> i\<close>
                  apply (clarsimp simp add: mem_box)
                  apply (subst sum_if_inner | force)+
                  done
                show "(\<Sum>(x,K) \<in> A. norm (integral K h)) < \<epsilon>/12"
                  apply (rule \<gamma>0 [OF cb_ab \<open>i \<in> Basis\<close> A_tagged fineA(1) \<open>h \<in> F\<close>])
                  using \<open>i \<in> Basis\<close> \<open>A \<subseteq> T''\<close> overlap
                  apply (subst sum_if_inner | force)+
                  done
                have 1: "(\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c})) ` A tagged_partial_division_of cbox a b"
                  using \<open>finite A\<close> \<open>i \<in> Basis\<close>
                  apply (auto simp: tagged_partial_division_of_def)
                  using A_tagged apply (auto simp: A_def)
                  using interval_split(1) by blast
                have 2: "\<gamma>0 fine (\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c})) ` A"
                  using fineA(1) fine_def by fastforce
                show "(\<Sum>(x,K) \<in> (\<lambda>(x,K). (x,K \<inter> {x. x \<bullet> i \<le> c})) ` A. norm (integral K h)) < \<epsilon>/12"
                  apply (rule \<gamma>0 [OF cb_ab \<open>i \<in> Basis\<close> 1 2 \<open>h \<in> F\<close>])
                  using \<open>i \<in> Basis\<close> apply (subst sum_if_inner | force)+
                  using overlap apply (auto simp: A_def)
                  done
                have *: "\<lbrakk>x < \<epsilon>/3; y < \<epsilon>/12; z < \<epsilon>/12\<rbrakk> \<Longrightarrow> x + y + z \<le> \<epsilon>/2" for x y z
                  by auto
                show "(\<Sum>(x,K) \<in> B. norm (?CI K h x)) +
                      (\<Sum>(x,K) \<in> B. norm (integral K h)) +
                      (\<Sum>(x,K) \<in> (\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B. norm (integral K h))
                      \<le> \<epsilon>/2"
                proof (rule *)
                  show "(\<Sum>(x,K) \<in> B. norm (?CI K h x)) < \<epsilon>/3"
                    by (intro h_less3 B_tagged fineB that)
                  show "(\<Sum>(x,K) \<in> B. norm (integral K h)) < \<epsilon>/12"
                    apply (rule \<gamma>0 [OF cb_ab \<open>i \<in> Basis\<close> B_tagged fineB(1) \<open>h \<in> F\<close>])
                    using \<open>i \<in> Basis\<close> \<open>B \<subseteq> T''\<close> overlap by (subst sum_if_inner | force)+
                  have 1: "(\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B tagged_partial_division_of cbox a b"
                    using \<open>finite B\<close> \<open>i \<in> Basis\<close>
                    apply (auto simp: tagged_partial_division_of_def)
                    using B_tagged apply (auto simp: B_def)
                    using interval_split(2) by blast
                  have 2: "\<gamma>0 fine (\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B"
                    using fineB(1) fine_def by fastforce
                  show "(\<Sum>(x,K) \<in> (\<lambda>(x,K). (x,K \<inter> {x. c \<le> x \<bullet> i})) ` B. norm (integral K h)) < \<epsilon>/12"
                    apply (rule \<gamma>0 [OF cb_ab \<open>i \<in> Basis\<close> 1 2 \<open>h \<in> F\<close>])
                    using \<open>i \<in> Basis\<close> apply (subst sum_if_inner | force)+
                    using overlap apply (auto simp: B_def)
                    done
                qed
              qed
            qed
            finally show ?thesis .
          qed
          ultimately show ?thesis by metis
        qed
        ultimately show ?thesis
          by (simp add: sum_subtractf [symmetric] int_KK' *)
      qed
        ultimately show ?thesis by metis
      next
        case False
        then consider "c < a \<bullet> i" | "b \<bullet> i < c"
          by auto
        then show ?thesis
        proof cases
          case 1
          then have f0: "f x = 0" if "x \<in> cbox a b" for x
            using that f \<open>i \<in> Basis\<close> mem_box(2) by force
          then have int_f0: "integral (cbox a b) f = 0"
            by (simp add: integral_cong)
          have f0_tag: "f x = 0" if "(x,K) \<in> T" for x K
            using T f0 that by (force simp: tagged_division_of_def)
          then have "(\<Sum>(x,K) \<in> T. content K *\<^sub>R f x) = 0"
            by (metis (mono_tags, lifting) real_vector.scale_eq_0_iff split_conv sum.neutral surj_pair)
          then show ?thesis
            using \<open>0 < \<epsilon>\<close> by (simp add: int_f0)
      next
          case 2
          then have fh: "f x = h x" if "x \<in> cbox a b" for x
            using that f \<open>i \<in> Basis\<close> mem_box(2) by force
          then have int_f: "integral (cbox a b) f = integral (cbox a b) h"
            using integral_cong by blast
          have fh_tag: "f x = h x" if "(x,K) \<in> T" for x K
            using T fh that by (force simp: tagged_division_of_def)
          then have "(\<Sum>(x,K) \<in> T. content K *\<^sub>R f x) = (\<Sum>(x,K) \<in> T. content K *\<^sub>R h x)"
            by (metis (mono_tags, lifting) split_cong sum.cong)
          with \<open>0 < \<epsilon>\<close> show ?thesis
            apply (simp add: int_f)
            apply (rule less_trans [OF \<gamma>1])
            using that fine_Int apply (force simp: divide_simps)+
            done
        qed
      qed
      have  "gauge (\<lambda>x. \<gamma>0 x \<inter> \<gamma>1 x)"
        by (simp add: \<open>gauge \<gamma>0\<close> \<open>gauge \<gamma>1\<close> gauge_Int)
      then show ?thesis
        by (auto intro: *)
    qed
  qed
qed



corollary%important equiintegrable_halfspace_restrictions_ge:
  fixes f :: "'a::euclidean_space \<Rightarrow> 'b::euclidean_space"
  assumes F: "F equiintegrable_on cbox a b" and f: "f \<in> F"
    and norm_f: "\<And>h x. \<lbrakk>h \<in> F; x \<in> cbox a b\<rbrakk> \<Longrightarrow> norm(h x) \<le> norm(f x)"
  shows "(\<Union>i \<in> Basis. \<Union>c. \<Union>h \<in> F. {(\<lambda>x. if x \<bullet> i \<ge> c then h x else 0)})
         equiintegrable_on cbox a b"
proof%unimportant -
  have *: "(\<Union>i\<in>Basis. \<Union>c. \<Union>h\<in>(\<lambda>f. f \<circ> uminus) ` F. {\<lambda>x. if x \<bullet> i \<le> c then h x else 0})
           equiintegrable_on  cbox (- b) (- a)"
  proof (rule equiintegrable_halfspace_restrictions_le)
    show "(\<lambda>f. f \<circ> uminus) ` F equiintegrable_on cbox (- b) (- a)"
      using F equiintegrable_reflect by blast
    show "f \<circ> uminus \<in> (\<lambda>f. f \<circ> uminus) ` F"
      using f by auto
    show "\<And>h x. \<lbrakk>h \<in> (\<lambda>f. f \<circ> uminus) ` F; x \<in> cbox (- b) (- a)\<rbrakk> \<Longrightarrow> norm (h x) \<le> norm ((f \<circ> uminus) x)"
      using f apply (clarsimp simp:)
      by (metis add.inverse_inverse image_eqI norm_f uminus_interval_vector)
  qed
  have eq: "(\<lambda>f. f \<circ> uminus) `
            (\<Union>i\<in>Basis. \<Union>c. \<Union>h\<in>F. {\<lambda>x. if x \<bullet> i \<le> c then (h \<circ> uminus) x else 0}) =
            (\<Union>i\<in>Basis. \<Union>c. \<Union>h\<in>F. {\<lambda>x. if c \<le> x \<bullet> i then h x else 0})"
    apply (auto simp: o_def cong: if_cong)
    using minus_le_iff apply fastforce
    apply (rule_tac x="\<lambda>x. if c \<le> (-x) \<bullet> i then h(-x) else 0" in image_eqI)
    using le_minus_iff apply fastforce+
    done
  show ?thesis
    using equiintegrable_reflect [OF *] by (auto simp: eq)
qed


proposition%important equiintegrable_closed_interval_restrictions:
  fixes f :: "'a::euclidean_space \<Rightarrow> 'b::euclidean_space"
  assumes f: "f integrable_on cbox a b"
  shows "(\<Union>c d. {(\<lambda>x. if x \<in> cbox c d then f x else 0)}) equiintegrable_on cbox a b"
proof%unimportant -
  let ?g = "\<lambda>B c d x. if \<forall>i\<in>B. c \<bullet> i \<le> x \<bullet> i \<and> x \<bullet> i \<le> d \<bullet> i then f x else 0"
  have *: "insert f (\<Union>c d. {?g B c d}) equiintegrable_on cbox a b" if "B \<subseteq> Basis" for B
  proof -
    have "finite B"
      using finite_Basis finite_subset \<open>B \<subseteq> Basis\<close> by blast
    then show ?thesis using \<open>B \<subseteq> Basis\<close>
    proof (induction B)
      case empty
      with f show ?case by auto
    next
      case (insert i B)
      then have "i \<in> Basis"
        by auto
      have *: "norm (h x) \<le> norm (f x)"
        if "h \<in> insert f (\<Union>c d. {?g B c d})" "x \<in> cbox a b" for h x
        using that by auto
      have "(\<Union>i\<in>Basis. 
                \<Union>\<xi>. \<Union>h\<in>insert f (\<Union>i\<in>Basis. \<Union>\<psi>. \<Union>h\<in>insert f (\<Union>c d. {?g B c d}). {\<lambda>x. if x \<bullet> i \<le> \<psi> then h x else 0}). 
                {\<lambda>x. if \<xi> \<le> x \<bullet> i then h x else 0}) 
             equiintegrable_on cbox a b"
      proof (rule equiintegrable_halfspace_restrictions_ge [where f=f])
        show "insert f (\<Union>i\<in>Basis. \<Union>\<xi>. \<Union>h\<in>insert f (\<Union>c d. {?g B c d}).
              {\<lambda>x. if x \<bullet> i \<le> \<xi> then h x else 0}) equiintegrable_on cbox a b"
          apply (intro * f equiintegrable_on_insert equiintegrable_halfspace_restrictions_le [OF insert.IH insertI1])
          using insert.prems apply auto
          done
        show"norm(h x) \<le> norm(f x)"
          if "h \<in> insert f (\<Union>i\<in>Basis. \<Union>\<xi>. \<Union>h\<in>insert f (\<Union>c d. {?g B c d}). {\<lambda>x. if x \<bullet> i \<le> \<xi> then h x else 0})" 
             "x \<in> cbox a b" for h x
          using that by auto
      qed auto
      then have "insert f (\<Union>i\<in>Basis. 
                \<Union>\<xi>. \<Union>h\<in>insert f (\<Union>i\<in>Basis. \<Union>\<psi>. \<Union>h\<in>insert f (\<Union>c d. {?g B c d}). {\<lambda>x. if x \<bullet> i \<le> \<psi> then h x else 0}). 
                {\<lambda>x. if \<xi> \<le> x \<bullet> i then h x else 0}) 
             equiintegrable_on cbox a b"
        by (blast intro: f equiintegrable_on_insert)
      then show ?case
        apply (rule equiintegrable_on_subset, clarify)
        using \<open>i \<in> Basis\<close> apply simp
        apply (drule_tac x=i in bspec, assumption)
        apply (drule_tac x="c \<bullet> i" in spec, clarify)
        apply (drule_tac x=i in bspec, assumption)
        apply (drule_tac x="d \<bullet> i" in spec)
        apply (clarsimp simp add: fun_eq_iff)
        apply (drule_tac x=c in spec)
        apply (drule_tac x=d in spec)
        apply (simp add: split: if_split_asm)
        done
    qed
  qed
  show ?thesis
    by (rule equiintegrable_on_subset [OF * [OF subset_refl]]) (auto simp: mem_box)
qed
  


subsection%important\<open>Continuity of the indefinite integral\<close>

proposition%important indefinite_integral_continuous:
  fixes f :: "'a :: euclidean_space \<Rightarrow> 'b :: euclidean_space"
  assumes int_f: "f integrable_on cbox a b"
      and c: "c \<in> cbox a b" and d: "d \<in> cbox a b" "0 < \<epsilon>"
  obtains \<delta> where "0 < \<delta>"
              "\<And>c' d'. \<lbrakk>c' \<in> cbox a b; d' \<in> cbox a b; norm(c' - c) \<le> \<delta>; norm(d' - d) \<le> \<delta>\<rbrakk>
                        \<Longrightarrow> norm(integral(cbox c' d') f - integral(cbox c d) f) < \<epsilon>"
proof%unimportant -
  { assume "\<exists>c' d'. c' \<in> cbox a b \<and> d' \<in> cbox a b \<and> norm(c' - c) \<le> \<delta> \<and> norm(d' - d) \<le> \<delta> \<and>
                    norm(integral(cbox c' d') f - integral(cbox c d) f) \<ge> \<epsilon>"
                    (is "\<exists>c' d'. ?\<Phi> c' d' \<delta>") if "0 < \<delta>" for \<delta>
    then have "\<exists>c' d'. ?\<Phi> c' d' (1 / Suc n)" for n
      by simp
    then obtain u v where "\<And>n. ?\<Phi> (u n) (v n) (1 / Suc n)"
      by metis
    then have u: "u n \<in> cbox a b" and norm_u: "norm(u n - c) \<le> 1 / Suc n"
         and  v: "v n \<in> cbox a b" and norm_v: "norm(v n - d) \<le> 1 / Suc n"
         and \<epsilon>: "\<epsilon> \<le> norm (integral (cbox (u n) (v n)) f - integral (cbox c d) f)" for n
      by blast+
    then have False
    proof -
      have uvn: "cbox (u n) (v n) \<subseteq> cbox a b" for n
        by (meson u v mem_box(2) subset_box(1))
      define S where "S \<equiv> \<Union>i \<in> Basis. {x. x \<bullet> i = c \<bullet> i} \<union> {x. x \<bullet> i = d \<bullet> i}"
      have "negligible S"
        unfolding S_def by force
      then have int_f': "(\<lambda>x. if x \<in> S then 0 else f x) integrable_on cbox a b"
        by (force intro: integrable_spike assms)
      have get_n: "\<exists>n. \<forall>m\<ge>n. x \<in> cbox (u m) (v m) \<longleftrightarrow> x \<in> cbox c d" if x: "x \<notin> S" for x
      proof -
        define \<epsilon> where "\<epsilon> \<equiv> Min ((\<lambda>i. min \<bar>x \<bullet> i - c \<bullet> i\<bar> \<bar>x \<bullet> i - d \<bullet> i\<bar>) ` Basis)"
        have "\<epsilon> > 0"
          using \<open>x \<notin> S\<close> by (auto simp: S_def \<epsilon>_def)
        then obtain n where "n \<noteq> 0" and n: "1 / (real n) < \<epsilon>"
          by (metis inverse_eq_divide real_arch_inverse)
        have emin: "\<epsilon> \<le> min \<bar>x \<bullet> i - c \<bullet> i\<bar> \<bar>x \<bullet> i - d \<bullet> i\<bar>" if "i \<in> Basis" for i
          unfolding \<epsilon>_def
          apply (rule Min.coboundedI)
          using that by force+
        have "1 / real (Suc n) < \<epsilon>"
          using n \<open>n \<noteq> 0\<close> \<open>\<epsilon> > 0\<close> by (simp add: field_simps)
        have "x \<in> cbox (u m) (v m) \<longleftrightarrow> x \<in> cbox c d" if "m \<ge> n" for m
        proof -
          have *: "\<lbrakk>\<bar>u - c\<bar> \<le> n; \<bar>v - d\<bar> \<le> n; N < \<bar>x - c\<bar>; N < \<bar>x - d\<bar>; n \<le> N\<rbrakk>
                   \<Longrightarrow> u \<le> x \<and> x \<le> v \<longleftrightarrow> c \<le> x \<and> x \<le> d" for N n u v c d and x::real
            by linarith
          have "(u m \<bullet> i \<le> x \<bullet> i \<and> x \<bullet> i \<le> v m \<bullet> i) = (c \<bullet> i \<le> x \<bullet> i \<and> x \<bullet> i \<le> d \<bullet> i)"
            if "i \<in> Basis" for i
          proof (rule *)
            show "\<bar>u m \<bullet> i - c \<bullet> i\<bar> \<le> 1 / Suc m"
              using norm_u [of m]
              by (metis (full_types) order_trans Basis_le_norm inner_commute inner_diff_right that)
            show "\<bar>v m \<bullet> i - d \<bullet> i\<bar> \<le> 1 / real (Suc m)"
              using norm_v [of m]
              by (metis (full_types) order_trans Basis_le_norm inner_commute inner_diff_right that)
            show "1/n < \<bar>x \<bullet> i - c \<bullet> i\<bar>" "1/n < \<bar>x \<bullet> i - d \<bullet> i\<bar>"
              using n \<open>n \<noteq> 0\<close> emin [OF \<open>i \<in> Basis\<close>]
              by (simp_all add: inverse_eq_divide)
            show "1 / real (Suc m) \<le> 1 / real n"
              using \<open>n \<noteq> 0\<close> \<open>m \<ge> n\<close> by (simp add: divide_simps)
          qed
          then show ?thesis by (simp add: mem_box)
        qed
        then show ?thesis by blast
      qed
      have 1: "range (\<lambda>n x. if x \<in> cbox (u n) (v n) then if x \<in> S then 0 else f x else 0) equiintegrable_on cbox a b"
        by (blast intro: equiintegrable_on_subset [OF equiintegrable_closed_interval_restrictions [OF int_f']])
      have 2: "(\<lambda>n. if x \<in> cbox (u n) (v n) then if x \<in> S then 0 else f x else 0)
               \<longlonglongrightarrow> (if x \<in> cbox c d then if x \<in> S then 0 else f x else 0)" for x
        by (fastforce simp: dest: get_n intro: Lim_eventually eventually_sequentiallyI)
      have [simp]: "cbox c d \<inter> cbox a b = cbox c d"
        using c d by (force simp: mem_box)
      have [simp]: "cbox (u n) (v n) \<inter> cbox a b = cbox (u n) (v n)" for n
        using u v by (fastforce simp: mem_box intro: order.trans)
      have "\<And>y A. y \<in> A - S \<Longrightarrow> f y = (\<lambda>x. if x \<in> S then 0 else f x) y"
        by simp
      then have "\<And>A. integral A (\<lambda>x. if x \<in> S then 0 else f (x)) = integral A (\<lambda>x. f (x))"
        by (blast intro: integral_spike [OF \<open>negligible S\<close>])
      moreover
      obtain N where "dist (integral (cbox (u N) (v N)) (\<lambda>x. if x \<in> S then 0 else f x))
                           (integral (cbox c d) (\<lambda>x. if x \<in> S then 0 else f x)) < \<epsilon>"
        using equiintegrable_limit [OF 1 2] \<open>0 < \<epsilon>\<close> by (force simp: integral_restrict_Int lim_sequentially)
      ultimately have "dist (integral (cbox (u N) (v N)) f) (integral (cbox c d) f) < \<epsilon>"
        by simp
      then show False
        by (metis dist_norm not_le \<epsilon>)
    qed
  }
  then show ?thesis
    by (meson not_le that)
qed

corollary%important indefinite_integral_uniformly_continuous:
  fixes f :: "'a :: euclidean_space \<Rightarrow> 'b :: euclidean_space"
  assumes "f integrable_on cbox a b"
  shows "uniformly_continuous_on (cbox (Pair a a) (Pair b b)) (\<lambda>y. integral (cbox (fst y) (snd y)) f)"
proof%unimportant -
  show ?thesis
  proof (rule compact_uniformly_continuous, clarsimp simp add: continuous_on_iff)
    fix c d and \<epsilon>::real
    assume c: "c \<in> cbox a b" and d: "d \<in> cbox a b" and "0 < \<epsilon>"
    obtain \<delta> where "0 < \<delta>" and \<delta>:
              "\<And>c' d'. \<lbrakk>c' \<in> cbox a b; d' \<in> cbox a b; norm(c' - c) \<le> \<delta>; norm(d' - d) \<le> \<delta>\<rbrakk>
                                  \<Longrightarrow> norm(integral(cbox c' d') f -
                                           integral(cbox c d) f) < \<epsilon>"
      using indefinite_integral_continuous \<open>0 < \<epsilon>\<close> assms c d by blast
    show "\<exists>\<delta> > 0. \<forall>x' \<in> cbox (a, a) (b, b).
                   dist x' (c, d) < \<delta> \<longrightarrow>
                   dist (integral (cbox (fst x') (snd x')) f)
                        (integral (cbox c d) f)
                   < \<epsilon>"
      using \<open>0 < \<delta>\<close>
      by (force simp: dist_norm intro: \<delta> order_trans [OF norm_fst_le] order_trans [OF norm_snd_le] less_imp_le)
  qed auto
qed


corollary%important bounded_integrals_over_subintervals:
  fixes f :: "'a :: euclidean_space \<Rightarrow> 'b :: euclidean_space"
  assumes "f integrable_on cbox a b"
  shows "bounded {integral (cbox c d) f |c d. cbox c d \<subseteq> cbox a b}"
proof%unimportant -
  have "bounded ((\<lambda>y. integral (cbox (fst y) (snd y)) f) ` cbox (a, a) (b, b))"
       (is "bounded ?I")
    by (blast intro: bounded_cbox bounded_uniformly_continuous_image indefinite_integral_uniformly_continuous [OF assms])
  then obtain B where "B > 0" and B: "\<And>x. x \<in> ?I \<Longrightarrow> norm x \<le> B"
    by (auto simp: bounded_pos)
  have "norm x \<le> B" if "x = integral (cbox c d) f" "cbox c d \<subseteq> cbox a b" for x c d
  proof (cases "cbox c d = {}")
    case True
    with \<open>0 < B\<close> that show ?thesis by auto
  next
    case False
    show ?thesis
      apply (rule B)
      using that \<open>B > 0\<close> False apply (clarsimp simp: image_def)
      by (metis cbox_Pair_iff interval_subset_is_interval is_interval_cbox prod.sel)
  qed
  then show ?thesis
    by (blast intro: boundedI)
qed


text\<open>An existence theorem for "improper" integrals.
Hake's theorem implies that if the integrals over subintervals have a limit, the integral exists.
We only need to assume that the integrals are bounded, and we get absolute integrability,
but we also need a (rather weak) bound assumption on the function.\<close>

theorem%important absolutely_integrable_improper:
  fixes f :: "'M::euclidean_space \<Rightarrow> 'N::euclidean_space"
  assumes int_f: "\<And>c d. cbox c d \<subseteq> box a b \<Longrightarrow> f integrable_on cbox c d"
      and bo: "bounded {integral (cbox c d) f |c d. cbox c d \<subseteq> box a b}"
      and absi: "\<And>i. i \<in> Basis
          \<Longrightarrow> \<exists>g. g absolutely_integrable_on cbox a b \<and>
                  ((\<forall>x \<in> cbox a b. f x \<bullet> i \<le> g x) \<or> (\<forall>x \<in> cbox a b. f x \<bullet> i \<ge> g x))"
      shows "f absolutely_integrable_on cbox a b"
proof%unimportant (cases "content(cbox a b) = 0")
  case True
  then show ?thesis
    by auto
next
  case False
  then have pos: "content(cbox a b) > 0"
    using zero_less_measure_iff by blast
  show ?thesis
    unfolding absolutely_integrable_componentwise_iff [where f = f]
  proof
    fix j::'N
    assume "j \<in> Basis"
    then obtain g where absint_g: "g absolutely_integrable_on cbox a b"
                    and g: "(\<forall>x \<in> cbox a b. f x \<bullet> j \<le> g x) \<or> (\<forall>x \<in> cbox a b. f x \<bullet> j \<ge> g x)"
      using absi by blast
    have int_gab: "g integrable_on cbox a b"
      using absint_g set_lebesgue_integral_eq_integral(1) by blast
    have 1: "cbox (a + (b - a) /\<^sub>R real (Suc n)) (b - (b - a) /\<^sub>R real (Suc n)) \<subseteq> box a b" for n
      apply (rule subset_box_imp)
      using pos apply (auto simp: content_pos_lt_eq algebra_simps)
      done
    have 2: "cbox (a + (b - a) /\<^sub>R real (Suc n)) (b - (b - a) /\<^sub>R real (Suc n)) \<subseteq>
             cbox (a + (b - a) /\<^sub>R real (Suc n + 1)) (b - (b - a) /\<^sub>R real (Suc n + 1))" for n
      apply (rule subset_box_imp)
      using pos apply (simp add: content_pos_lt_eq algebra_simps)
        apply (simp add: divide_simps)
      apply (auto simp: field_simps)
      done
    have getN: "\<exists>N::nat. \<forall>k. k \<ge> N \<longrightarrow> x \<in> cbox (a + (b - a) /\<^sub>R real k) (b - (b - a) /\<^sub>R real k)"
      if x: "x \<in> box a b" for x
    proof -
      let ?\<Delta> = "(\<Union>i \<in> Basis. {((x - a) \<bullet> i) / ((b - a) \<bullet> i), (b - x) \<bullet> i / ((b - a) \<bullet> i)})"
      obtain N where N: "real N > 1 / Inf ?\<Delta>"
        using reals_Archimedean2 by blast
      moreover have \<Delta>: "Inf ?\<Delta> > 0"
        using that by (auto simp: finite_less_Inf_iff mem_box algebra_simps divide_simps)
      ultimately have "N > 0"
        using of_nat_0_less_iff by fastforce
      show ?thesis
      proof (intro exI impI allI)
        fix k assume "N \<le> k"
        with \<open>0 < N\<close> have "k > 0"
          by linarith
        have xa_gt: "(x - a) \<bullet> i > ((b - a) \<bullet> i) / (real k)" if "i \<in> Basis" for i
        proof -
          have *: "Inf ?\<Delta> \<le> ((x - a) \<bullet> i) / ((b - a) \<bullet> i)"
            using that by (force intro: cInf_le_finite)
          have "1 / Inf ?\<Delta> \<ge> ((b - a) \<bullet> i) / ((x - a) \<bullet> i)"
            using le_imp_inverse_le [OF * \<Delta>]
            by (simp add: field_simps)
          with N have "k > ((b - a) \<bullet> i) / ((x - a) \<bullet> i)"
            using \<open>N \<le> k\<close> by linarith
          with x that show ?thesis
            by (auto simp: mem_box algebra_simps divide_simps)
        qed
        have bx_gt: "(b - x) \<bullet> i > ((b - a) \<bullet> i) / k" if "i \<in> Basis" for i
        proof -
          have *: "Inf ?\<Delta> \<le> ((b - x) \<bullet> i) / ((b - a) \<bullet> i)"
            using that by (force intro: cInf_le_finite)
          have "1 / Inf ?\<Delta> \<ge> ((b - a) \<bullet> i) / ((b - x) \<bullet> i)"
            using le_imp_inverse_le [OF * \<Delta>]
            by (simp add: field_simps)
          with N have "k > ((b - a) \<bullet> i) / ((b - x) \<bullet> i)"
            using \<open>N \<le> k\<close> by linarith
          with x that show ?thesis
            by (auto simp: mem_box algebra_simps divide_simps)
        qed
        show "x \<in> cbox (a + (b - a) /\<^sub>R k) (b - (b - a) /\<^sub>R k)"
          using that \<Delta> \<open>k > 0\<close>
          by (auto simp: mem_box algebra_simps divide_inverse dest: xa_gt bx_gt)
      qed
    qed
    obtain Bf where "Bf > 0" and Bf: "\<And>c d. cbox c d \<subseteq> box a b \<Longrightarrow> norm (integral (cbox c d) f) \<le> Bf"
      using bo unfolding bounded_pos by blast
    obtain Bg where "Bg > 0" and Bg:"\<And>c d. cbox c d \<subseteq> cbox a b \<Longrightarrow> \<bar>integral (cbox c d) g\<bar> \<le> Bg"
      using bounded_integrals_over_subintervals [OF int_gab] unfolding bounded_pos real_norm_def by blast
    show "(\<lambda>x. f x \<bullet> j) absolutely_integrable_on cbox a b"
      using g
    proof     \<comment> \<open>A lot of duplication in the two proofs\<close>
      assume fg [rule_format]: "\<forall>x\<in>cbox a b. f x \<bullet> j \<le> g x"
      have "(\<lambda>x. (f x \<bullet> j)) = (\<lambda>x. g x - (g x - (f x \<bullet> j)))"
        by simp
      moreover have "(\<lambda>x. g x - (g x - (f x \<bullet> j))) integrable_on cbox a b"
      proof (rule Henstock_Kurzweil_Integration.integrable_diff [OF int_gab])
        let ?\<phi> = "\<lambda>k x. if x \<in> cbox (a + (b - a) /\<^sub>R (Suc k)) (b - (b - a) /\<^sub>R (Suc k))
                        then g x - f x \<bullet> j else 0"
        have "(\<lambda>x. g x - f x \<bullet> j) integrable_on box a b"
        proof (rule monotone_convergence_increasing [of ?\<phi>, THEN conjunct1])
          have *: "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k)) \<inter> box a b
                 = cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))" for k
            using box_subset_cbox "1" by fastforce
          show "?\<phi> k integrable_on box a b" for k
            apply (simp add: integrable_restrict_Int integral_restrict_Int *)
            apply (rule integrable_diff [OF integrable_on_subcbox [OF int_gab]])
            using "*" box_subset_cbox apply blast
            by (metis "1" int_f integrable_component of_nat_Suc)
          have cb12: "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))
                    \<subseteq> cbox (a + (b - a) /\<^sub>R (2 + real k)) (b - (b - a) /\<^sub>R (2 + real k))" for k
            using False content_eq_0
            apply (simp add: subset_box algebra_simps)
            apply (simp add: divide_simps)
            apply (fastforce simp: field_simps)
            done
          show "?\<phi> k x \<le> ?\<phi> (Suc k) x" if "x \<in> box a b" for k x
            using cb12 box_subset_cbox that by (force simp: intro!: fg)
          show "(\<lambda>k. ?\<phi> k x) \<longlonglongrightarrow> g x - f x \<bullet> j" if x: "x \<in> box a b" for x
          proof (rule Lim_eventually)
            obtain N::nat where N: "\<And>k. k \<ge> N \<Longrightarrow> x \<in> cbox (a + (b - a) /\<^sub>R real k) (b - (b - a) /\<^sub>R real k)"
              using getN [OF x] by blast
            show "\<forall>\<^sub>F k in sequentially. ?\<phi> k x = g x - f x \<bullet> j"
            proof
              fix k::nat assume "N \<le> k"
              have "x \<in> cbox (a + (b - a) /\<^sub>R (Suc k)) (b - (b - a) /\<^sub>R (Suc k))"
                by (metis \<open>N \<le> k\<close> le_Suc_eq N)
              then show "?\<phi> k x = g x - f x \<bullet> j"
                by simp
            qed
          qed
          have "\<bar>integral (box a b)
                      (\<lambda>x. if x \<in> cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))
                           then g x - f x \<bullet> j else 0)\<bar> \<le> Bg + Bf" for k
          proof -
            let ?I = "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))"
            have I_int [simp]: "?I \<inter> box a b = ?I"
              using 1 by (simp add: Int_absorb2)
            have int_fI: "f integrable_on ?I"
              apply (rule integrable_subinterval [OF int_f order_refl])
              using "*" box_subset_cbox by blast
            then have "(\<lambda>x. f x \<bullet> j) integrable_on ?I"
              by (simp add: integrable_component)
            moreover have "g integrable_on ?I"
              apply (rule integrable_subinterval [OF int_gab])
              using "*" box_subset_cbox by blast
            moreover
            have "\<bar>integral ?I (\<lambda>x. f x \<bullet> j)\<bar> \<le> norm (integral ?I f)"
              by (simp add: Basis_le_norm int_fI \<open>j \<in> Basis\<close>)
            with 1 I_int have "\<bar>integral ?I (\<lambda>x. f x \<bullet> j)\<bar> \<le> Bf"
              by (blast intro: order_trans [OF _ Bf])
            ultimately show ?thesis
              apply (simp add: integral_restrict_Int integral_diff)
              using "*" box_subset_cbox by (blast intro: Bg add_mono order_trans [OF abs_triangle_ineq4])
          qed
          then show "bounded (range (\<lambda>k. integral (box a b) (?\<phi> k)))"
            apply (simp add: bounded_pos)
            apply (rule_tac x="Bg+Bf" in exI)
            using \<open>0 < Bf\<close> \<open>0 < Bg\<close>  apply auto
            done
        qed
        then show "(\<lambda>x. g x - f x \<bullet> j) integrable_on cbox a b"
          by (simp add: integrable_on_open_interval)
      qed
      ultimately have "(\<lambda>x. f x \<bullet> j) integrable_on cbox a b"
        by auto
      then show ?thesis
        apply (rule absolutely_integrable_component_ubound [OF _ absint_g])
        by (simp add: fg)
    next
      assume gf [rule_format]: "\<forall>x\<in>cbox a b. g x \<le> f x \<bullet> j"
      have "(\<lambda>x. (f x \<bullet> j)) = (\<lambda>x. ((f x \<bullet> j) - g x) + g x)"
        by simp
      moreover have "(\<lambda>x. (f x \<bullet> j - g x) + g x) integrable_on cbox a b"
      proof (rule Henstock_Kurzweil_Integration.integrable_add [OF _ int_gab])
        let ?\<phi> = "\<lambda>k x. if x \<in> cbox (a + (b - a) /\<^sub>R (Suc k)) (b - (b - a) /\<^sub>R (Suc k))
                        then f x \<bullet> j - g x else 0"
        have "(\<lambda>x. f x \<bullet> j - g x) integrable_on box a b"
        proof (rule monotone_convergence_increasing [of ?\<phi>, THEN conjunct1])
          have *: "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k)) \<inter> box a b
                 = cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))" for k
            using box_subset_cbox "1" by fastforce
          show "?\<phi> k integrable_on box a b" for k
            apply (simp add: integrable_restrict_Int integral_restrict_Int *)
            apply (rule integrable_diff)
              apply (metis "1" int_f integrable_component of_nat_Suc)
             apply (rule integrable_on_subcbox [OF int_gab])
            using "*" box_subset_cbox apply blast
              done
          have cb12: "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))
                    \<subseteq> cbox (a + (b - a) /\<^sub>R (2 + real k)) (b - (b - a) /\<^sub>R (2 + real k))" for k
            using False content_eq_0
            apply (simp add: subset_box algebra_simps)
            apply (simp add: divide_simps)
            apply (fastforce simp: field_simps)
            done
          show "?\<phi> k x \<le> ?\<phi> (Suc k) x" if "x \<in> box a b" for k x
            using cb12 box_subset_cbox that by (force simp: intro!: gf)
          show "(\<lambda>k. ?\<phi> k x) \<longlonglongrightarrow> f x \<bullet> j - g x" if x: "x \<in> box a b" for x
          proof (rule Lim_eventually)
            obtain N::nat where N: "\<And>k. k \<ge> N \<Longrightarrow> x \<in> cbox (a + (b - a) /\<^sub>R real k) (b - (b - a) /\<^sub>R real k)"
              using getN [OF x] by blast
            show "\<forall>\<^sub>F k in sequentially. ?\<phi> k x = f x \<bullet> j - g x"
            proof
              fix k::nat assume "N \<le> k"
              have "x \<in> cbox (a + (b - a) /\<^sub>R (Suc k)) (b - (b - a) /\<^sub>R (Suc k))"
                by (metis \<open>N \<le> k\<close> le_Suc_eq N)
              then show "?\<phi> k x = f x \<bullet> j - g x"
                by simp
            qed
          qed
          have "\<bar>integral (box a b)
                      (\<lambda>x. if x \<in> cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))
                           then f x \<bullet> j - g x else 0)\<bar> \<le> Bf + Bg" for k
          proof -
            let ?I = "cbox (a + (b - a) /\<^sub>R (1 + real k)) (b - (b - a) /\<^sub>R (1 + real k))"
            have I_int [simp]: "?I \<inter> box a b = ?I"
              using 1 by (simp add: Int_absorb2)
            have int_fI: "f integrable_on ?I"
              apply (rule integrable_subinterval [OF int_f order_refl])
              using "*" box_subset_cbox by blast
            then have "(\<lambda>x. f x \<bullet> j) integrable_on ?I"
              by (simp add: integrable_component)
            moreover have "g integrable_on ?I"
              apply (rule integrable_subinterval [OF int_gab])
              using "*" box_subset_cbox by blast
            moreover
            have "\<bar>integral ?I (\<lambda>x. f x \<bullet> j)\<bar> \<le> norm (integral ?I f)"
              by (simp add: Basis_le_norm int_fI \<open>j \<in> Basis\<close>)
            with 1 I_int have "\<bar>integral ?I (\<lambda>x. f x \<bullet> j)\<bar> \<le> Bf"
              by (blast intro: order_trans [OF _ Bf])
            ultimately show ?thesis
              apply (simp add: integral_restrict_Int integral_diff)
              using "*" box_subset_cbox by (blast intro: Bg add_mono order_trans [OF abs_triangle_ineq4])
          qed
          then show "bounded (range (\<lambda>k. integral (box a b) (?\<phi> k)))"
            apply (simp add: bounded_pos)
            apply (rule_tac x="Bf+Bg" in exI)
            using \<open>0 < Bf\<close> \<open>0 < Bg\<close>  by auto
        qed
        then show "(\<lambda>x. f x \<bullet> j - g x) integrable_on cbox a b"
          by (simp add: integrable_on_open_interval)
      qed
      ultimately have "(\<lambda>x. f x \<bullet> j) integrable_on cbox a b"
        by auto
      then show ?thesis
        apply (rule absolutely_integrable_component_lbound [OF absint_g])
        by (simp add: gf)
    qed
  qed
qed

end
  
