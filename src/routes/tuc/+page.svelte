<script lang="ts">
	import Worm from '../worms/Worm.svelte';
	import Snake from './Snake.svelte';
	let showWardrobe = false;
	let hideAll = false;
</script>

<svelte:head>
	<title>TUC</title>
	<meta name="description" content="This is TUC game" />
</svelte:head>

<svg id="back">
	<defs>
		<pattern id="stripes" patternUnits="userSpaceOnUse" width="20" height="20">
			<path d="M-1,1 l2,-2 M0,20 l20,-20 M19,21 l2,-2" stroke="#000" stroke-width="1" />
			<circle cx="5" cy="5" r="12" stroke="black" stroke-width="1" fill="green" />
		</pattern>
	</defs>
	<rect width="100%" height="100%" fill="url(#stripes)" />
</svg>

{#if !hideAll}
	<div id="buttons">
		<svg><rect width="100%" height="100%" id="blue-rect" /></svg>
		<button class="big-button" on:click={() => (hideAll = true)}>play now &#x25B6;</button>
		<button class="big-button" on:click={() => (showWardrobe = true)}>wardrobe!</button>
	</div>
{:else}
	<button on:click={() => (hideAll = false)}>back ⇇</button>
	<Snake />
	<Worm kp={0.04} ki={0.0005} kd={0.05} size={40} />
	<Worm />
	<Worm kp={0.02} ki={0.0001} kd={0.1} size={24} />
	<Worm kp={0.01} ki={0.00001} kd={0.2} size={16} />
	<Worm kp={0.005} ki={0.00001} kd={0.2} size={8} />
	<Worm kp={0.0025} ki={0.00001} kd={0.2} size={4} />
{/if}

{#if showWardrobe}
	<div id="wardrobe">
		<div class="container">
			<div>select your skin</div>
			<button class="close" on:click={() => (showWardrobe = false)}>x</button>
		</div>
	</div>
{/if}

<style>
	#back {
		background-color: purple;
		top: 0px;
		left: 0px;
		width: 100%;
		height: 100%;
		z-index: -1;
		position: absolute;
	}
	#buttons {
		/* display: flex; */
	}
	#blue-rect {
		fill: rgb(0, 0, 255);
		stroke-width: 3;
		stroke: rgb(0, 0, 0);
	}
	.big-button {
		height: 129px;
		width: 200px;
		font-size: 39px;
		font-weight: 900;
		color: blanchedalmond;
		background-color: #8516ec;
	}
	#wardrobe {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		width: 90%;
		height: 299px;
		background-color: blue;
		color: white;
		padding: 20px;
		z-index: 3;
	}
	.container {
		display: flex;
	}
	.close {
		margin-left: auto;
	}
</style>
