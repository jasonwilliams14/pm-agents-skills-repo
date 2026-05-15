const { execSync } = require('child_process');

/**
 * Runs markdownlint-cli on the docs directory and provides concise output.
 */
try {
  console.log('Running markdownlint-cli on docs/...');
  const output = execSync('npx markdownlint-cli docs/', { encoding: 'utf8' });
  console.log('✅ Documentation is valid!');
  if (output) console.log(output);
} catch (error) {
  console.error('❌ Documentation linting failed:');
  const stderr = error.stderr || error.message;
  const lines = stderr.split('\n');
  if (lines.length > 50) {
    console.error(lines.slice(0, 50).join('\n'));
    console.error(`... and ${lines.length - 50} more errors.`);
  } else {
    console.error(stderr);
  }
  process.exit(1);
}
