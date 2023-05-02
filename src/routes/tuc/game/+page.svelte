<script lang="ts">
	import { onMount } from 'svelte';
	import Worm from './Worm.svelte';
	import Snake from './Snake.svelte';
	let exercises = ['2^5', '3^3', '5*3', '45+45+110', '5^4', '2^4', '10^4', '3^0', '1^-1', '20^3'];
	let seeds: any[] = [];
	let size = 56;
	onMount(
		() =>
			(seeds = exercises.map((exercise) => {
				return {
					exercise: exercise,
					x: Math.random() * 100,
					y: Math.random() * 100,
					size: size
				};
			}))
	);
</script>

<svelte:head>
	<title>TUC Game</title>
	<meta name="description" content="This is TUC game" />
</svelte:head>

<a href="/tuc"><button>back ⇇</button></a>
<div id="seeds">
	{#each seeds as seed}
		<div class="seed" style="width:{size}px;height:{size}px;left:{seed.x}%;top:{seed.y}%">
			<h4>{seed.exercise}</h4>
		</div>
	{/each}
</div>
<Worm kp={0.0001} ki={0.000001} kd={0.07} {seeds}><Snake /></Worm>



<style>
	a button {
		width: 100%;
	}
	#seeds {
		width: 100%;
		height: 100%;
	}
	.seed {
		position: absolute;
		background: #663399bb;
		z-index: -1;
	}
</style>
