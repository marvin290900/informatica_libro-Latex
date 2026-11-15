-- Filtro Pandoc para detectar pies de foto/tabla debajo de una imagen
-- y convertirlos automáticamente a \pieFoto{...}

local function tiene_imagen(bloque)
  if not bloque or (bloque.t ~= "Para" and bloque.t ~= "Plain") then
    return false
  end
  for _, el in ipairs(bloque.content) do
    if el.t == "Image" then
      return true
    end
  end
  return false
end

local function es_pie_de_foto(bloque)
  if not bloque or (bloque.t ~= "Para" and bloque.t ~= "Plain") then
    return false
  end

  -- Extrae texto plano limpio (ignora si viene en negrita, cursiva o texto normal)
  local texto = pandoc.utils.stringify(bloque):gsub("^%s+", "")
  if texto == "" then
    return false
  end

  -- 1. Detecta "Figura <número>" o "Tabla <número>" (ej. Figura 5.4..., Tabla 6.1....)
  --    Permite espacios, puntos o dos puntos después del número y no distingue mayúsculas/minúsculas
  local texto_lower = texto:lower()
  if texto_lower:match("^figura%s+%d+") or texto_lower:match("^tabla%s+%d+") then
    return true
  end

  -- 2. Mantiene tu validación original: si el párrafo completo o su inicio está en cursiva
  local primer_el = bloque.content[1]
  if primer_el and primer_el.t == "Emph" then
    return true
  end

  return false
end

function Blocks(blocks)
  local resultado = {}
  local i = 1

  while i <= #blocks do
    local actual = blocks[i]
    local siguiente = blocks[i + 1]

    if tiene_imagen(actual) and es_pie_de_foto(siguiente) then
      table.insert(resultado, actual)
      -- Convierte el párrafo siguiente completo a LaTeX y lo envuelve en \pieFoto{...}
      local latex_pie = pandoc.write(pandoc.Pandoc({siguiente}), "latex"):gsub("%s+$", "")
      table.insert(resultado, pandoc.RawBlock("latex", "\\pieFoto{" .. latex_pie .. "}"))
      i = i + 2
    else
      table.insert(resultado, actual)
      i = i + 1
    end
  end

  return resultado
end