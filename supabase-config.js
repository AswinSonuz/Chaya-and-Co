async function testSupabase() {
    const { data, error } = await supabaseClient
        .from('votes')
        .select('*')
        .limit(5);

    if (error) {
        console.error("SUPABASE ERROR:", error);
        alert("Connection failed: " + error.message);
    } else {
        console.log("Supabase connected successfully!", data);
    }
}

testSupabase();
