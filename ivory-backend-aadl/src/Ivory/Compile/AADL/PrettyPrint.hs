
module Ivory.Compile.AADL.PrettyPrint where

import Ivory.Compile.AADL.AST
import Text.PrettyPrint.Leijen
import System.IO

tab :: Doc -> Doc
tab = indent 2

documentToFile :: FilePath -> Document -> IO ()
documentToFile f d = withFile f WriteMode $ \h -> displayIO h rendered
  where
  w = 1000000 -- don't wrap lines 
  rendered = renderPretty 1.0 w $ aadlDoc d

aadlDoc :: Document -> Doc
aadlDoc d = vsep $
  [ text "-- AADL Document autogenerated by Ivory.Language.AADL"
  , empty
  , text "package" <+> pkg
  , text "public"
  , tab $ vsep $ map docImport (doc_imports d)
  , empty
  , vsep $ map docDefinition (doc_definitions d)
  , empty
  , text "end" <+> pkg <> semi
  ]
  where
  pkg = text (doc_name d)

docImport :: String -> Doc
docImport s = text "with" <+> text s <> semi

docDefinition :: Definition -> Doc
docDefinition (TypeDefinition dtypedef)    = docDTypeDef dtypedef   <$> empty
docDefinition (ThreadDefinition threaddef) = docThreadDef threaddef <$> empty
docDefinition (ProcessDefinition pdef)     = docProcessDef pdef     <$> empty

docDTypeDef :: DTypeDef -> Doc
docDTypeDef (DTStruct tname fields) = vsep
  [ docBlock "data" t
      [ docSection "properties"
          [ kv (text "Data_Model::Data_Representation") (text "Struct")
          ]
      ] 
  , empty
  , docBlock "data implementation" ti
      [ docSection "subcomponents"
          (map docDTField fields)
      ]
  ]
  where
  t  = string tname
  ti = t <> dot <> text "impl"

docDTypeDef (DTArray tname len basetype) =
  docBlock "data" t
    [ docSection "properties"
      [ dmodel "Data_Representation" $ text "Array"
      , dmodel "Base_Type"           $ parens btype
      , dmodel "Dimension"           $ parens (int len)
      ]
    ]
  where
  t = text tname
  dmodel field v = kv (text ("Data_Model::" ++ field)) v
  btype = text "classifier" <+> parens (docTypeName basetype)

docBlock :: String -> Doc -> [Doc] -> Doc
docBlock opener name body = text opener <+> name 
                         <$> tab (vsep body)
                         <$> text "end" <+> name <> semi
                         <$> empty

docSection :: String -> [Doc] -> Doc
docSection secname props = text secname <$> tab (vsep props)

docDTField :: DTField -> Doc
docDTField (DTField name tname) =
  text name <+> colon <+> text "data" <+> docTypeName tname <> semi

docTypeName :: TypeName -> Doc
docTypeName (UnqualTypeName s)   = text s
docTypeName (QualTypeName a b)   = text a <> colon <> colon <> text b
docTypeName (DotTypeName n a)    = docTypeName n <> dot <> text a

docThreadDef :: ThreadDef -> Doc
docThreadDef (ThreadDef threadname features properties) =
  docBlock "thread" t
    [ docSection "features"
        (map docThreadFeature features)
    , docSection "properties"
        (map docThreadProperty properties)
    ]
  where
  t = text threadname

docThreadFeature :: ThreadFeature -> Doc
docThreadFeature (ThreadFeaturePort n k d tname props) =
  text n <> colon <+> dd <+> kk <+> (docTypeName tname) <> ps
  where
  dd = case d of
    In  -> text "in"
    Out -> text "out"
  kk = case k of
    PortKindData  -> text "data port"
    PortKindEvent -> text "event data port"
  ps = case props of
    [] -> empty
    _  -> space <> braces (line <> tab values <> line) <> semi
      where values = vsep (map docThreadProperty props)

docThreadProperty :: ThreadProperty -> Doc
docThreadProperty (ThreadProperty k v) = kv (text k) (docPropValue v)
docThreadProperty (UnprintableThreadProperty str) = text ("-- " ++ str)

docPropValue (PropInteger n) = integer n
docPropValue (PropUnit n unit) = integer n <+> text unit
docPropValue (PropString s) = dquotes (text s)
docPropValue (PropLiteral s) = text s
docPropValue (PropList l) = parens (hcat (punctuate (comma <> space) (map docPropValue l)))

kv :: Doc -> Doc -> Doc
kv k v = k <+> text "=>" <+> v <> semi

---

docProcessDef :: ProcessDef -> Doc
docProcessDef (ProcessDef procname comps conns) = vsep
  [ docBlock "process" p []
  , empty
  , docBlock "process" (p <> text ".impl")
      [ docSection "subcomponents"
          (map docProcComponent comps)
      , docSection "connections"
          (map docProcConnection conns)
      ]
  ]
  where
  p = text procname

docProcComponent :: ProcessComponent -> Doc
docProcComponent (ProcessComponent name ttype) = 
  text name <+> colon <+> text "thread" <+> text ttype <> semi

docProcConnection :: ProcessConnection -> Doc
docProcConnection (ProcessConnection to fro) =
  text "port" <+> docProcessPort to <+> text "->" <+> docProcessPort fro <> semi

docProcessPort :: ProcessPort -> Doc
docProcessPort (ProcessPort n p) =
  text n <> dot <> text p

