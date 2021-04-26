const { Octokit } = require("@octokit/action");

const octokit = new Octokit();

get_async()

async function get_async () {
  for (var i=0; i < 10; i++) {
    const result = await octokit.request('GET /repos/Homebrew/homebrew-core/actions/runners')
    const { runners: [{ status, busy }] } = result.data
    console.log("Result: %s", status);
    console.log("Result: %s", busy);
    if (busy == false) {
      return true;
      break;
    }

    await new Promise(resolve => setTimeout(resolve, 5000));
  }

}
