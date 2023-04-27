<script lang="ts">
	import Worm from './Worm.svelte';
</script>

<svelte:head>
	<title>Worms</title>
	<meta name="description" content="Worms game" />
</svelte:head>

<Worm kp={0.04} ki={0.0005} kd={0.05} size={40} />
<Worm />
<Worm kp={0.02} ki={0.0001} kd={0.1} size={24} />
<Worm kp={0.01} ki={0.00001} kd={0.2} size={16} />
