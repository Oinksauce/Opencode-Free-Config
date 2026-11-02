# Opencode-Free-Config

A ready-made [OpenCode](https://opencode.ai) setup that lets one coding session run a small team of AI helpers on free models, and move to another model on its own when one runs out.

## What it does

- **A team in one session.** The [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) plugin gives OpenCode an orchestrator that splits a job and hands parts to helpers: an explorer (reads and searches the code), a fixer (makes edits), an oracle (reviews and reasons) and a designer (UI). Helpers can work at the same time.
- **Clean handoffs when a model runs out.** Each helper has an ordered list of models. When the current one is rate-limited or over quota, the session switches to the next model and retries the same turn with the full conversation, so work continues without you choosing a new model.
- **Free by default.** The default preset uses only OpenCode Zen's free models, which need no account or key. Adding free keys from other providers gives each helper more models to fall back to.

Tested on 2026-11-01 with OpenCode 2.2.5 (CLI and desktop app) on macOS: two helpers fixed a file at the same time, and a real rate-limit error moved the session to the next model, which answered in about 9 seconds.

## Install

```bash
git clone https://github.com/Oinksauce/Opencode-Free-Config.git ~/Opencode-Free-Config
~/Opencode-Free-Config/install.sh
~/Opencode-Free-Config/test.sh
```

`install.sh` works on macOS and Linux. It installs OpenCode if it is missing, backs up any existing OpenCode config files it would replace (`*.bak-<date>`), and links this repo's `config/` folder into `~/.config/opencode`. That includes `AGENTS.md`, OpenCode's instructions for every session; it currently asks for math in LaTeX (`$$...$$`), which the desktop app renders as formatted equations. Add your own instructions there. To update later, run `git -C ~/Opencode-Free-Config pull`.

`test.sh` checks that every model in the active preset answers, then has two helpers fix a small buggy file at the same time. `./test.sh models` runs only the first check.

Then start OpenCode (`opencode` in a terminal, or the desktop app) and give it a job with two separate parts, for example: "Explain this folder and fix the bug in X at the same time."

## Choose a preset

Set `"preset"` in `config/oh-my-opencode-slim.jsonc`, or type `/preset <name>` in OpenCode.

| Preset | Keys needed | Fallback order for each helper |
|---|---|---|
| `free` (default) | none | OpenCode Zen free models only |
| `free-nvidia` | NVIDIA | Zen, then NVIDIA |
| `free-nvidia-openrouter` | NVIDIA, OpenRouter | Zen, then NVIDIA, then OpenRouter |

Use a preset only when you have every key it needs. A model whose provider has no key on your machine stops the session ("Model unavailable") instead of being skipped. Add keys with `opencode auth login`.

Each step in a list uses a different provider, because usage limits usually belong to the account, not the model. In the `free` preset every step is on Zen, so a Zen-wide limit stops all of them at once; that is the reason to add a second provider.

## Providers

Limits and terms change often. Checked 2026-11-01 against each provider's own pages unless noted; confirm before relying on them. Free tiers may log your prompts or use them for training, so don't send anything private through them.

**Free, no card**

| Provider | What you get | Data use | Setup |
|---|---|---|---|
| [OpenCode Zen](https://opencode.ai/docs/zen/) free models | About ten models, each free "for a limited time". Works only inside OpenCode. Usage limit not published. | GLM-5.3-Flash Free and DeepSeek V4.1 Flash Free: no retention, no training. Big Pickle, MiMo and Nemotron: prompts may be used to improve the model. | None |
| [NVIDIA NIM](https://build.nvidia.com) | Many open models, up to 40 requests/minute (checked October 2026). Some models time out at busy times. | Not checked | Free key |
| [OpenRouter](https://openrouter.ai) `:free` models | 20 requests/minute; 50 requests/day, or 1,000/day after a one-time $10 credit purchase | Set per model by the underlying provider | Free key |
| [Groq](https://console.groq.com/docs/rate-limits) | gpt-oss-120b and qwen3.8-27b: 30 requests/minute, 1,000/day, 8,000 tokens/minute. **Doesn't work with this setup on the free tier:** one request from this setup is about 15,000 tokens (measured 2026-11-01), so Groq rejects it. Fine for small scripts; for agents it needs a paid Groq tier. | Not checked | Free key |
| [Google AI Studio](https://aistudio.google.com) | Free tier on Gemini and Gemma models | Free-tier prompts may be used to improve Google's products (outside the EU, UK and EEA) | Free key |
| [Mistral](https://console.mistral.ai) | Free "Experiment" tier; reports from September and October 2026 differ on which models a new account can use | Free-tier prompts are used for training unless you opt out | Free key, phone verification |
| ChatGPT Free (Codex CLI) | OpenAI says Codex is included with ChatGPT Free, with limited, unpublished usage. It runs in OpenAI's own `codex` CLI. Whether a Free account also works inside OpenCode is untested (see the ChatGPT row below). | See OpenAI's data controls | Free ChatGPT account |
| A model on your own computer | No limits beyond your hardware | Stays on your machine | See "Adding a local model" |

**Low-cost**

| Option | Cost | Notes |
|---|---|---|
| OpenRouter credits | $10 one time | Raises the free-model limit from 50 to 1,000 requests/day. Credits also pay for non-free models. |
| [OpenCode Go](https://opencode.ai/go) | $10/month ($5 first month) | Stronger open models, capped at $12 of usage per 5 hours, $30 per week and $60 per month |
| [Ollama Cloud](https://ollama.com/pricing) | Pay per token, or Pro at $20/month with $60 of usage | No longer free: since late October 2026 every cloud model is billed per token. Local Ollama models stay free. |
| GitHub Copilot | Free, Student (free), or $10 to $100/month | See "Students: GitHub Copilot Student" below. Connect with `opencode auth login github-copilot`. |
| ChatGPT subscription in OpenCode | Your ChatGPT plan | `opencode auth login openai --method chatgpt-browser`, then approve in the browser. Tested 2026-11-01 on a paid plan: GPT-6 Luna, GPT-6.1 Sol and GPT-6 Astra all answered. Add `openai/<model>` to the lists to use it as a fallback step. |
| Cerebras | $5 trial credit, card required, expires after 30 days | The no-card free tier ended in July 2026 (per Cerebras's changelog as quoted by trackers) |

Not listed: GitHub Models (reports conflict on whether it was retired in July 2026), Cloudflare Workers AI (context windows too small for coding), and providers that third-party lists still call free but whose own pages showed no free models on 2026-11-01: Z.ai (GLM), Hugging Face Inference Providers (free accounts get no credits), Chutes and SambaNova. GLM's Flash models are free through OpenCode Zen instead.

To see OpenRouter's current free models: `curl -s https://openrouter.ai/api/v1/models | grep -o '"id":"[^"]*:free"'`. On 2026-11-01 there were 14, and all but one support tool calls.

To use any of these, add the key, then add its models to the lists in `config/oh-my-opencode-slim.jsonc` (`provider/model`, as shown by `opencode models`).

## Students: GitHub Copilot Student

Verified students get GitHub's **Copilot Student** plan for free. It replaced free Copilot Pro for students in March 2026; free Copilot Pro is now only for verified teachers and maintainers of popular open-source projects. Many guides online still describe the old offer.

**Who qualifies** (from GitHub's [student application requirements](https://docs.github.com/en/education/about-github-education/github-education-for-students/apply-to-github-education-as-a-student)):

- At least 13 years old, with a personal GitHub account
- Enrolled in a degree- or diploma-granting program: high school, college, university or homeschool
- Proof of enrollment: a school email address, a photo of a school ID showing the current enrollment date, or an enrollment letter. If your school doesn't issue email addresses, a school webpage or letter explaining that policy works instead.

**What the plan includes** (from GitHub's [plan comparison](https://docs.github.com/en/copilot/get-started/plans), checked 2026-11-01):

- A monthly allowance of GitHub AI Credits. GitHub doesn't publish the amount for Free and Student; Copilot Pro ($10/month) includes 1,500.
- **Auto model selection only**: GitHub picks the model, and you can't choose a specific one.
- **Excludes third-party agents.**

**Does it work in this setup?** Untested. The last two limits may stop it: OpenCode asks for a specific model by name, and GitHub may count OpenCode as a third-party agent. If you're a student with the plan, run `opencode auth login github-copilot`, then `opencode models | grep github-copilot`. If models appear, test one with `opencode run -m github-copilot/<model> "Reply with just: ok"`. Either way, the plan works in GitHub's own tools (VS Code, the GitHub website and GitHub's Copilot CLI).

Third-party coverage reports that GitHub paused new sign-ups for some Copilot plans in April 2026. GitHub's plans page linked to Student sign-up on 2026-11-01; check there if your application stalls.

**How to apply:** [apply to GitHub Education](https://education.github.com/discount_requests/application) as a student. After approval, which can take a few days, Copilot Student appears under Copilot settings on your GitHub profile.

## Family and subscription plans

Some consumer AI plans can be shared with family, but they usually cover the vendor's own apps rather than API keys that OpenCode can use.

Google AI Pro is an example. It can be shared with up to five family members through a Google One family group. The sharing covers the Gemini app and, for members who are 18 or older, Google's Antigravity coding tool. It does not include a Gemini API key: Google's documentation says the plan's developer benefits apply inside the AI Studio website, and API use is billed separately. The plan does include $10 a month in Google Cloud credits through the Google Developer Program, which Google says can be spent on Gemini through Vertex AI. Users report that the credits cannot fund AI Studio API billing.

Community plugins that sign OpenCode in with a Google account (`opencode-antigravity-auth` and forks) are unofficial, and their own documentation warns that accounts have been banned. This setup does not use them.

## Adding a local model

A model on your own computer never runs out, which makes it a good last step in every list. With [Ollama](https://ollama.com) installed and a model pulled (for example `ollama pull qwen3-coder:30b`), uncomment the `provider` block in `config/opencode.jsonc` and add `ollama/<model>` to the end of each list. Check that the model can use tools: some local models describe edits instead of making them.

## Watching the helpers

Inside a terminal multiplexer ([Herdr](https://herdr.dev) or tmux), helpers that work in the background open as panes beside the main session (`multiplexer.type: auto`). The panes are for watching; typing into them does nothing.

## Known gaps

- A provider with no key stops the session instead of being skipped (see "Choose a preset").
- `opencode run` (non-interactive) ends when the orchestrator's turn ends, which stops helpers running in the background. `test.sh` asks the helpers to work side by side and wait instead. In normal interactive use, background helpers are fine.
- Helpers' reports of which model they used are not reliable. The OpenCode logs show the real model.
- Shell commands ask before running (`permission.bash: ask` in `config/opencode.jsonc`).

## Trying it on a Mac without changing your own setup

`./try-on-mac.sh` installs into `~/.config-freeteam` and reopens the OpenCode desktop app with that config, using its own background service so your usual one is untouched. Quit and reopen the app normally to go back.

## Credits

Built on [OpenCode](https://github.com/anomalyco/opencode) and [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim).
