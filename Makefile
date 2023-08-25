generated/Images.elm: codegen/Generate.elm
	yarn elm-codegen run --flags-from public
	elm-format --yes generated
