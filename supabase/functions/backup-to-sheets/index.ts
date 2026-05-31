import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { sheetId, data } = await req.json();

    if (!sheetId) {
      return new Response(
        JSON.stringify({ error: "sheetId is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const googleSheetsUrl = `https://sheets.googleapis.com/v4/spreadsheets/${sheetId}/values/Sheet1!A1`;
    const accessToken = Deno.env.get("GOOGLE_SHEETS_ACCESS_TOKEN");

    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: "Google Sheets token not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Prepare data for Google Sheets
    const values = data.map((row: Record<string, unknown>) => [
      row.name,
      row.phone,
      row.soldBy,
      row.packages,
      row.totalPaid,
    ]);

    const response = await fetch(googleSheetsUrl, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        values: [
          ["Name", "Phone", "Sold By", "Packages", "Total Paid"],
          ...values,
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`Google Sheets API error: ${response.statusText}`);
    }

    const result = await response.json();

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
