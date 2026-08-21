# Constructors a generic has methods for, derived from the methods defined in the
# namespace so the hint stays current as sub-models are added. A fit subclass is
# named after its constructor (kb_fit_weight_nereo() returns a kb_fit_weight_nereo
# object), so a method's class doubles as the function to point the reader at.
# Intersecting with the exports drops parent classes such as kb_fit, which no
# constructor is named after, leaving an empty result for the generics that take
# any fit.
.fit_constructors <- function(generic) {
  ns <- asNamespace("kelpbio")
  prefix <- paste0(generic, ".")
  # all.names so a dot-prefixed generic's methods are visible at all, and
  # startsWith rather than a regex so its leading dot stays literal.
  nms <- ls(ns, all.names = TRUE)
  classes <- setdiff(
    substring(nms[startsWith(nms, prefix)], nchar(prefix) + 1L),
    "default"
  )
  sort(intersect(classes, getNamespaceExports(ns)))
}

# Terminal abort for a generic reached with an object it has no method for.
# Named .abort_ rather than .chk_: "a method is registered for this class" is not
# a validity property of the object, so there is no .vld_ partner to pair with.
# Reached only after the class check has passed, so the object is a supported
# parent class carrying an unsupported subclass.
# `generic = NULL` is the internal-generic form: one internal generic serves
# several public verbs, so naming it would name something the user never called.
.abort_no_method <- function(
  generic = NULL,
  x,
  x_name = deparse(substitute(x)),
  call = rlang::caller_env()
) {
  if (is.null(generic)) {
    cli::cli_abort(
      c(
        "kelpbio has no method for a {.cls {class(x)[1]}} object.",
        i = "Supported fits are created by the {.code kb_fit_*()} functions."
      ),
      call = call
    )
  }
  constructors <- .fit_constructors(generic)
  cli::cli_abort(
    c(
      "{.fun {generic}} has no method for {.arg {x_name}}, a {.cls {class(x)[1]}} object.",
      i = if (length(constructors)) {
        "Supported fits are created by {.fun {constructors}}."
      } else {
        "Supported fits are created by the {.code kb_fit_*()} functions."
      }
    ),
    call = call
  )
}
