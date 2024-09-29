import starlight from '@astrojs/starlight';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
    integrations: [
        starlight({
            title: 'Beamer',
            social: {
                github: 'https://github.com/slovnicki/beamer',
                discord: 'https://discord.com/invite/8hDJ7tP5Mz',
            },
            sidebar: [
                { 
                    label: 'Getting Started',
                    items: ['getting-started/install', 'getting-started/about'],
                },
                { 
                    label: 'Quick Start',
                    items: ['quick-start/routes-stack-builder'],
                },
                { 
                    label: 'Key Concepts',
                    items: [
                        'concepts/stack',
                        'concepts/state',
                        'concepts/guard',
                        'concepts/interceptor',
                        'concepts/nested-navigation',
                        'concepts/navigating',
                    ],
                },
                {
                    label: 'Contributing',
                    items: ['contributing'],
                }
            ],
        }),
    ],
});
