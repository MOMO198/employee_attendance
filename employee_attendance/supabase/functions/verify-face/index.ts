import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.168.0/encoding/base64.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { image, userId } = await req.json()

    // Créer un client Supabase
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Récupérer la photo de profil de l'utilisateur
    const { data: profileData, error: profileError } = await supabaseClient
      .from('profiles')
      .select('photo_url')
      .eq('id', userId)
      .single()

    if (profileError) throw profileError

    // Appeler le service Python de vérification faciale
    const pythonServiceUrl = Deno.env.get('PYTHON_SERVICE_URL')
    const response = await fetch(`${pythonServiceUrl}/verify-face`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        current_image: image,
        profile_image_url: profileData.photo_url,
      }),
    })

    const result = await response.json()

    return new Response(
      JSON.stringify({ verified: result.verified }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
}) 