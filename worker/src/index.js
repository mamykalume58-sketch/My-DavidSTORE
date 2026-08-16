export default {
  async fetch(request, env, ctx) {
    return new Response(JSON.stringify({ status: 'ok', message: 'DavidSTORE Worker en ligne' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
};
